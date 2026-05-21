--原石の鳴獰
-- 效果：
-- ①：支付2000基本分，宣言1个通常怪兽的卡名才能发动。直到对方回合结束时，自己的宣言的通常怪兽以及自己的「原石」怪兽不会被战斗破坏。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从卡组守备表示特殊召唤。
-- ②：对方把怪兽召唤的场合，把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽低的攻击力的场上1只怪兽除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（发动时宣言通常怪兽卡名并赋予战破抗性，满足条件可特召）和②效果（对方召唤时墓地除外，以场上/墓地通常怪兽为对象，除外场上低攻击力怪兽）。
function s.initial_effect(c)
	-- ①：支付2000基本分，宣言1个通常怪兽的卡名才能发动。直到对方回合结束时，自己的宣言的通常怪兽以及自己的「原石」怪兽不会被战斗破坏。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽召唤的场合，把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽低的攻击力的场上1只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.rmcon)
	-- 设置效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价函数：检查并支付2000基本分。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分。
	Duel.PayLPCost(tp,2000)
end
-- ①效果的发动准备：让玩家宣言1个通常怪兽的卡名，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家宣言卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_NORMAL,OPCODE_ISTYPE,5405694,OPCODE_ISCODE,OPCODE_OR,OPCODE_AND}
	-- 让玩家宣言一个符合过滤条件（通常怪兽）的卡名。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名保存为效果处理时的参数。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为宣言卡名。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	-- 设置当前连锁的操作信息为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 战破抗性适用对象的过滤条件：自己的「原石」怪兽或宣言的通常怪兽。
function s.ptfilter(e,c)
	return c:IsSetCard(0x1b9) or (c:IsCode(e:GetLabel()) and c:IsType(TYPE_NORMAL))
end
-- 特殊召唤对象的过滤条件：卡组中与宣言卡名相同且可以守备表示特殊召唤的通常怪兽。
function s.smfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsType(TYPE_NORMAL)
end
-- ①效果的处理：赋予「原石」怪兽及宣言的通常怪兽战破抗性；若自己场上没有怪兽，可选择将宣言的通常怪兽从卡组守备表示特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时宣言的卡名。
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 直到对方回合结束时，自己的宣言的通常怪兽以及自己的「原石」怪兽不会被战斗破坏。自己场上没有怪兽存在的场合，可以再把宣言的1只通常怪兽从卡组守备表示特殊召唤。②：对方把怪兽召唤的场合，把墓地的这张卡除外，以自己的场上·墓地1只通常怪兽为对象才能发动。持有比那只怪兽低的攻击力的场上1只怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	e1:SetLabel(code)
	-- 将战破抗性的场地效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
	-- 检查自己场上是否存在怪兽。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查卡组中是否存在可特殊召唤的宣言的通常怪兽。
		and Duel.IsExistingMatchingCard(s.smfilter,tp,LOCATION_DECK,0,1,nil,e,tp,code)
		-- 询问玩家是否要将宣言的怪兽特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否要把宣言的怪兽特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组选择1只符合条件的通常怪兽。
			local g=Duel.SelectMatchingCard(tp,s.smfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
			if g:GetCount()>0 then
				-- 将选择的怪兽以守备表示特殊召唤。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
	end
end
-- 对方召唤的怪兽的过滤条件。
function s.rmcfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp)
end
-- ②效果的发动条件：对方把怪兽召唤的场合。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmcfilter,1,nil,tp)
end
-- 作为效果对象的通常怪兽的过滤条件：自己场上或墓地的表侧表示通常怪兽，且场上存在攻击力比其低的怪兽。
function s.rmfilter1(c,tp)
	-- 检查该卡是否为表侧表示的通常怪兽，且场上是否存在攻击力比其低并能被除外的怪兽。
	return c:IsType(TYPE_NORMAL) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.rmfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 准备除外的场上怪兽的过滤条件：表侧表示、攻击力低于作为对象的怪兽、且可以被除外。
function s.rmfilter2(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk and c:IsAbleToRemove()
end
-- ②效果的发动准备：选择自己场上或墓地1只通常怪兽作为对象，并设置除外的操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter1(chkc,tp) end
	-- 检查自己场上或墓地是否存在符合条件的通常怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择作为效果对象的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
	-- 优先从场上（其次从墓地）选择1只符合条件的通常怪兽作为对象。
	aux.SelectTargetFromFieldFirst(tp,s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置当前连锁的操作信息为除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
-- ②效果的处理：除外场上1只攻击力低于作为对象的怪兽的怪兽。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此连锁中作为对象的怪兽。
	local tc=Duel.GetTargetsRelateToChain():GetFirst()
	-- 检查作为对象的怪兽是否仍表侧表示存在，且场上是否存在攻击力比其低的怪兽。
	if tc and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.rmfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc:GetAttack()) then
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择场上1只攻击力低于作为对象的怪兽的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.rmfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		if g:GetCount()>0 then
			-- 给选中的卡片显示被选择的动画效果。
			Duel.HintSelection(g)
			-- 将选中的怪兽除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
