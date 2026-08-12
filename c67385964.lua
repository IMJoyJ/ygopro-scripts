--剣闘獣ノクシウス
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。这张卡不会被那次战斗破坏。
-- ②：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合才能发动。从卡组把1只「剑斗兽」怪兽送去墓地。
-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 罪斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c67385964.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。这张卡不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67385964,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c67385964.hspcon)
	e1:SetTarget(c67385964.hsptg)
	e1:SetOperation(c67385964.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合才能发动。从卡组把1只「剑斗兽」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67385964,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置发动条件为用「剑斗兽」怪兽的效果特殊召唤成功
	e2:SetCondition(aux.gbspcon)
	e2:SetTarget(c67385964.tgtg)
	e2:SetOperation(c67385964.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 罪斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67385964,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c67385964.spcon)
	e3:SetCost(c67385964.spcost)
	e3:SetTarget(c67385964.sptg)
	e3:SetOperation(c67385964.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：对方怪兽直接攻击宣言时
function c67385964.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local at=Duel.GetAttacker()
	-- 检查攻击怪兽是否由对方控制，且攻击对象为空（即直接攻击）
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果①的发动准备（检查怪兽区域是否有空位，以及此卡是否能特殊召唤）
function c67385964.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：特殊召唤此卡，转移攻击对象并进行伤害计算，且此卡不会被该次战斗破坏
function c67385964.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将此卡以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前的攻击怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 这张卡不会被那次战斗破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			c:RegisterEffect(e1)
			-- 强制让攻击怪兽与此卡进行战斗伤害计算
			Duel.CalculateDamage(a,c)
		end
	end
end
-- 过滤条件：卡组中的「剑斗兽」怪兽卡
function c67385964.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1019) and c:IsAbleToGrave()
end
-- 效果②的发动准备（检查卡组中是否存在可送去墓地的「剑斗兽」怪兽）
function c67385964.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「剑斗兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67385964.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1只「剑斗兽」怪兽送去墓地
function c67385964.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 过滤并让玩家从卡组选择1张满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c67385964.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果③的发动条件：此卡进行过战斗
function c67385964.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果③的发动代价：让这张卡回到持有者卡组
function c67385964.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将此卡作为发动代价洗回持有者卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：卡组中「剑斗兽 罪斗」以外的、可以特殊召唤的「剑斗兽」怪兽
function c67385964.filter(c,e,tp)
	return not c:IsCode(67385964) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备（检查怪兽区域空位以及卡组中是否存在可特殊召唤的「剑斗兽」怪兽）
function c67385964.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价回卡组，所以可用空位限制为>-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在满足特殊召唤条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c67385964.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组特殊召唤1只「剑斗兽 罪斗」以外的「剑斗兽」怪兽
function c67385964.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从卡组选择1只满足特殊召唤条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c67385964.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
