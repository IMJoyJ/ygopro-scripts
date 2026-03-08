--原石の号咆
-- 效果：
-- ①：宣言1个通常怪兽的卡名才能发动。这个回合，自己的宣言的通常怪兽以及自己的「原石」怪兽的战斗发生的对自己的战斗伤害变成0。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从自己的卡组·墓地特殊召唤。
-- ②：对方回合把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽高的攻击力的对方场上1只怪兽的控制权直到结束阶段得到。
local s,id,o=GetID()
-- 注册两个效果：①宣言通常怪兽卡名并特殊召唤；②对方回合时从墓地除外并获得控制权
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
	-- 将此卡从场上除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gctg)
	e2:SetOperation(s.gcop)
	c:RegisterEffect(e2)
end
-- 处理效果①的宣言与特殊召唤逻辑
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_NORMAL,OPCODE_ISTYPE,5405694,OPCODE_ISCODE,OPCODE_OR,OPCODE_AND}
	-- 让玩家选择宣言一个通常怪兽卡号
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号设置为连锁参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息：宣告卡号
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	-- 设置操作信息：准备特殊召唤宣言的通常怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 判断是否可以特殊召唤宣言的通常怪兽
function s.smfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 处理效果①的发动逻辑：设置战斗伤害为0并判断是否特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取宣言的卡号
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 设置战斗伤害为0的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(code)
	-- 注册战斗伤害为0的效果
	Duel.RegisterEffect(e1,tp)
	-- 判断自己场上是否没有怪兽
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判断卡组或墓地是否存在宣言的通常怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.smfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,code)
		-- 询问玩家是否特殊召唤宣言的通常怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否要把宣言的怪兽特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的通常怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.smfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,code)
			if g:GetCount()>0 then
				-- 将选中的通常怪兽特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
	end
end
-- 判断是否为原石怪兽或宣言的通常怪兽
function s.ptfilter(e,c)
	return c:IsSetCard(0x1b9) or (c:IsCode(e:GetLabel()) and c:IsType(TYPE_NORMAL))
end
-- 判断是否为对方回合
function s.gccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 筛选场上或墓地的通常怪兽
function s.gcfilter1(c,tp)
	-- 筛选场上或墓地的通常怪兽并判断其攻击力
	return c:IsType(TYPE_NORMAL) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.gcfilter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 筛选攻击力高于目标的对方怪兽
function s.gcfilter2(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk and c:IsControlerCanBeChanged()
end
-- 处理效果②的目标选择与控制权转移逻辑
function s.gctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.gcfilter1(chkc,tp) end
	-- 判断是否存在符合条件的目标
	if chk==0 then return Duel.IsExistingTarget(s.gcfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
	-- 优先从场上选择目标
	aux.SelectTargetFromFieldFirst(tp,s.gcfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：获得控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 处理效果②的控制权转移逻辑
function s.gcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁相关的对象卡片
	local tc=Duel.GetTargetsRelateToChain():GetFirst()
	-- 判断目标是否为通常怪兽且攻击力足够
	if tc and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.gcfilter2,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack()) then
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择攻击力高于目标的对方怪兽
		local g=Duel.SelectMatchingCard(tp,s.gcfilter2,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		if g:GetCount()>0 then
			-- 显示选中怪兽的动画效果
			Duel.HintSelection(g)
			-- 获得选中怪兽的控制权直到结束阶段
			Duel.GetControl(g:GetFirst(),tp,PHASE_END,1)
		end
	end
end
