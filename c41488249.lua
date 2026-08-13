--原石の号咆
-- 效果：
-- ①：宣言1个通常怪兽的卡名才能发动。这个回合，自己的宣言的通常怪兽以及自己的「原石」怪兽的战斗发生的对自己的战斗伤害变成0。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从自己的卡组·墓地特殊召唤。
-- ②：对方回合把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽高的攻击力的对方场上1只怪兽的控制权直到结束阶段得到。
local s,id,o=GetID()
-- 定义该卡初始化函数，注册①效果（宣言通常怪兽并给予战斗伤害减免/可特召）与②效果（对方回合除外自身取对象夺控）。
function s.initial_effect(c)
	-- ①：宣言1个通常怪兽的卡名才能发动。这个回合，自己的宣言的通常怪兽以及自己的「原石」怪兽的战斗发生的对自己的战斗伤害变成0。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从自己的卡组·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"宣言"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方回合把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽高的攻击力的对方场上1只怪兽的控制权直到结束阶段得到。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"获得控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.gccon)
	-- 设置②效果的发动COST为把墓地的这张卡除外（使用通用墓地除外代价函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gctg)
	e2:SetOperation(s.gcop)
	c:RegisterEffect(e2)
end
-- 效果①的发动时处理：进行卡名宣言并登记特殊召唤的操作信息；若为发动合法性检查则直接返回true。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向tp玩家发送“请宣言一个卡名”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_NORMAL,OPCODE_ISTYPE,5405694,OPCODE_ISCODE,OPCODE_OR,OPCODE_AND}
	-- 调用宣言卡片接口，让tp玩家宣言1张符合过滤条件（通常怪兽等限定）的卡名。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号保存到当前连锁的目标参数中，供效果处理时获取。
	Duel.SetTargetParam(ac)
	-- 登记该连锁具有“宣言卡名”的类别，供相关效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	-- 登记该连锁可能从卡组·墓地特殊召唤1只怪兽的类别信息（对象数量为1，位置为卡组+墓地）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 定义特殊召唤筛选函数：卡名是宣言的卡、为通常怪兽且可以被特殊召唤。
function s.smfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果①的处理：获取宣言卡名，给自己场上适用战斗伤害变为0的效果；若自己场上无怪兽且存在可特召的宣言通常怪兽，则询问玩家是否将其特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时宣言的卡名代码。
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- ①：宣言1个通常怪兽的卡名才能发动。这个回合，自己的宣言的通常怪兽以及自己的「原石」怪兽的战斗发生的对自己的战斗伤害变成0。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从自己的卡组·墓地特殊召唤。②：对方回合把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽高的攻击力的对方场上1只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(code)
	-- 将战斗伤害减免的持续效果注册到tp玩家场上，当回合适用。
	Duel.RegisterEffect(e1,tp)
	-- 判断tp玩家自己场上是否没有怪兽（用于决定是否追加特殊召唤）。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查卡组·墓地是否存在宣言的通常怪兽且可特殊召唤（并排除王家长眠之谷的影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.smfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,code)
		-- 在满足条件时，询问tp玩家是否要把宣言的怪兽特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要把宣言的怪兽特殊召唤？"
			-- 向tp玩家发送“请选择要特殊召唤的卡”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组·墓地选择1只符合条件的宣言通常怪兽（使用王谷过滤）。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.smfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,code)
			if g:GetCount()>0 then
				-- 将选择的怪兽以表侧攻击表示特殊召唤到tp玩家自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
	end
end
-- 定义战斗伤害减免的适用对象：我方场上的「原石」怪兽或宣言的通常怪兽。
function s.ptfilter(e,c)
	return c:IsSetCard(0x1b9) or (c:IsCode(e:GetLabel()) and c:IsType(TYPE_NORMAL))
end
-- 定义②效果的发动条件：仅在对方回合才能发动。
function s.gccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为tp的对方玩家（即是否对方回合）。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义②效果可选择的我方通常怪兽的条件：表侧通常怪兽且对方场上有攻击力比它高的可夺控怪兽。
function s.gcfilter1(c,tp)
	-- 目标必须是表侧通常怪兽，且对方场上有攻击力高于它的可改变控制权的怪兽。
	return c:IsType(TYPE_NORMAL) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.gcfilter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 定义对方场上可夺取控制权的怪兽条件：表侧表示、攻击力高于目标怪兽、且控制权可改变。
function s.gcfilter2(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk and c:IsControlerCanBeChanged()
end
-- ②效果的取对象处理：选择自己场上·墓地1只符合条件的通常怪兽，并登记获得控制权的操作信息。
function s.gctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.gcfilter1(chkc,tp) end
	-- 发动合法性检查：确认自己场上·墓地是否存在至少1只符合条件的通常怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.gcfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 向tp玩家发送“请选择”对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
	-- 使用辅助选择函数，优先从场上选择对象（场上不足时再从墓地选择），并设为效果对象。
	aux.SelectTargetFromFieldFirst(tp,s.gcfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 登记该连锁具有“获得控制权”的类别，供相关卡片判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- ②效果处理：取回对象通常怪兽，若其仍合法且对方场上有攻击力更高的怪兽，则选择1只并获得其控制权直到结束阶段。
function s.gcop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出与本连锁相关的第1只对象怪兽（即自己场上·墓地选择的通常怪兽）。
	local tc=Duel.GetTargetsRelateToChain():GetFirst()
	-- 确认对象怪兽仍表侧表示且为怪兽，且对方场上有攻击力高于它的可夺控怪兽。
	if tc and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.gcfilter2,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack()) then
		-- 向tp玩家发送“请选择要改变控制权的怪兽”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 从对方场上选择1只攻击力高于目标怪兽且可改变控制权的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.gcfilter2,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		if g:GetCount()>0 then
			-- 显示所选怪兽的选中动画，并记录其被选为对象。
			Duel.HintSelection(g)
			-- 直到结束阶段获得所选对方怪兽的控制权。
			Duel.GetControl(g:GetFirst(),tp,PHASE_END,1)
		end
	end
end
