--六武式襲双陣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从以下效果选1个适用。自己场上有「六武众」怪兽2只以上存在的场合，可以选两方适用。
-- ●从自己的手卡·墓地把1只攻击力2000以下的「六武众」怪兽特殊召唤。
-- ●对方场上1只攻击力2000以下的怪兽变成里侧守备表示。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①效果（发动时选择1个效果）和②效果（墓地发动）
function s.initial_effect(c)
	-- ①：从以下效果选1个适用。自己场上有「六武众」怪兽2只以上存在的场合，可以选两方适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「六武众」怪兽（攻击力2000以下，可特殊召唤）
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足条件的对方场上表侧表示怪兽（攻击力2000以下，可变为里侧守备表示）
function s.posfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(2000) and c:IsCanTurnSet()
end
-- 过滤满足条件的「六武众」怪兽（表侧表示）
function s.bfilter(c)
	return c:IsSetCard(0x103d) and c:IsFaceup()
end
-- 判断是否可以发动①效果：自己场上存在可特殊召唤的怪兽或对方场上存在可变为里侧守备表示的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位且手卡/墓地存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡/墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 或对方场上是否存在满足条件的怪兽
		or Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 处理①效果的发动选择：根据条件显示选项并执行对应操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡/墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	-- 判断对方场上是否存在满足条件的怪兽
	local b2=Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)  --"特殊召唤"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)  --"改变表示形式"
		opval[off-1]=2
		off=off+1
	end
	-- 判断自己场上是否存在2只以上「六武众」怪兽，用于显示选择两方适用的选项
	if b1 and b2 and Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_MZONE,0,2,nil) then
		ops[off]=aux.Stringid(id,2)  --"选择2方"
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	-- 让玩家选择要发动的效果
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif opval[op]==2 then
		-- 提示玩家选择要变为里侧守备表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示选中的怪兽被选为对象
			Duel.HintSelection(g)
			-- 将选中的怪兽变为里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	elseif opval[op]==3 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤
		if g:GetCount()>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
		-- 提示玩家选择要变为里侧守备表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择满足条件的怪兽
		local cg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=cg:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 显示选中的怪兽被选为对象
			Duel.HintSelection(g)
			-- 将选中的怪兽变为里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 过滤满足条件的「六武众」怪兽（可加入手牌）
function s.thfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 处理②效果的发动：选择墓地的「六武众」怪兽加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 判断墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示要将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理②效果的发动：将选中的怪兽加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽加入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
