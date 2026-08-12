--魔界劇団－リバティ・ドラマチスト
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时，丢弃1张手卡才能发动。这张卡在对方场上特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡从灵摆区域的特殊召唤成功的场合发动。这张卡的原本持有者从自身卡组把3张「魔界台本」魔法卡给对方观看，对方从那之中随机选1张。那1张卡在自身场上盖放，剩下的卡回到卡组。这个效果盖放的卡在结束阶段破坏。
-- ②：这张卡被破坏的场合才能发动。从自己墓地选1张「魔界台本」魔法卡回到卡组。
function c65477143.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：自己或者对方的怪兽的攻击宣言时，丢弃1张手卡才能发动。这张卡在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65477143,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,65477143)
	e1:SetCost(c65477143.atkcost)
	e1:SetTarget(c65477143.atktg)
	e1:SetOperation(c65477143.atkop)
	c:RegisterEffect(e1)
	-- ①：这张卡从灵摆区域的特殊召唤成功的场合发动。这张卡的原本持有者从自身卡组把3张「魔界台本」魔法卡给对方观看，对方从那之中随机选1张。那1张卡在自身场上盖放，剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65477143,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,65477144)
	e2:SetCondition(c65477143.thcon)
	e2:SetOperation(c65477143.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏的场合才能发动。从自己墓地选1张「魔界台本」魔法卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65477143,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,65477145)
	e3:SetTarget(c65477143.tdtg)
	e3:SetOperation(c65477143.tdop)
	c:RegisterEffect(e3)
end
-- 灵摆效果①的Cost（丢弃手卡）判定与执行函数
function c65477143.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 灵摆效果①的Target（特殊召唤）判定与操作信息设置函数
function c65477143.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可用的怪兽区域，以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的Operation（特殊召唤）执行函数
function c65477143.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在对方场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否是从灵摆区域特殊召唤成功
function c65477143.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
-- 过滤卡组中可以盖放的「魔界台本」魔法卡
function c65477143.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSSetable() and c:IsSetCard(0x20ec)
end
-- 怪兽效果①的Operation（展示、随机选1张盖放、其余回卡组、注册结束阶段破坏）执行函数
function c65477143.thop(e,tp,eg,ep,ev,re,r,rp)
	local ts=e:GetHandler():GetOwner()
	-- 获取原本持有者卡组中所有满足条件的「魔界台本」魔法卡
	local g=Duel.GetMatchingGroup(c65477143.thfilter,ts,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示原本持有者选择要盖放（展示）的卡
		Duel.Hint(HINT_SELECTMSG,ts,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(ts,3,3,nil)
		-- 向对方玩家展示选出的3张卡
		Duel.ConfirmCards(1-ts,sg)
		-- 提示对方玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,1-ts,HINTMSG_SET)  --"请选择要盖放的卡"
		local tg=sg:RandomSelect(1-ts,1)
		local tc=tg:GetFirst()
		-- 如果成功将对方随机选出的那1张卡在原本持有者场上盖放
		if tc and Duel.SSet(tp,tc,ts,false)~=0 then
			-- 将原本持有者的卡组洗牌
			Duel.ShuffleDeck(ts)
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(65477143,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这个效果盖放的卡在结束阶段破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c65477143.tgcon)
			e1:SetOperation(c65477143.tgop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册在结束阶段破坏该盖放卡的效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 检查该盖放卡是否仍存在于场上且带有对应标记
function c65477143.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(65477143)==e:GetLabel()
end
-- 执行结束阶段破坏该盖放卡的效果
function c65477143.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果破坏目标卡片
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 过滤自己墓地中可以回到卡组的「魔界台本」魔法卡
function c65477143.tdfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 怪兽效果②的Target（回到卡组）判定与操作信息设置函数
function c65477143.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以回到卡组的「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65477143.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置将墓地的卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 怪兽效果②的Operation（回到卡组）执行函数
function c65477143.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张「魔界台本」魔法卡
	local g=Duel.SelectMatchingCard(tp,c65477143.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
