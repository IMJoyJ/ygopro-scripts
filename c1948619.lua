--X・HERO ワンダー・ドライバー
-- 效果：
-- 「英雄」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：作为这张卡所连接区的自己场上有「英雄」怪兽召唤·特殊召唤的场合，以自己墓地的「融合」魔法卡、「变化」速攻魔法卡的其中1张为对象发动。那张卡在自己场上盖放。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从手卡把1只「英雄」怪兽特殊召唤。
function c1948619.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只「英雄」怪兽作为连接素材进行连接召唤（素材数量固定为2）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2,2)
	-- 效果①对应的效果原文：这个卡名的①的效果1回合只能使用1次。①：作为这张卡所连接区的自己场上有「英雄」怪兽召唤·特殊召唤的场合，以自己墓地的「融合」魔法卡、「变化」速攻魔法卡的其中1张为对象发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1948619,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,1948619)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1948619.setcon)
	e1:SetTarget(c1948619.settg)
	e1:SetOperation(c1948619.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果②对应的效果原文：②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从手卡把1只「英雄」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c1948619.spcon)
	e3:SetTarget(c1948619.sptg)
	e3:SetOperation(c1948619.spop)
	c:RegisterEffect(e3)
end
-- 该过滤函数用于判断事件中的怪兽是否为“被召唤/特殊召唤到这张卡所连接区的自己场上的「英雄」怪兽”：若该怪兽仍在场上，检查其正面表示、由自己控制且位于本卡的连接区；若已离场，则根据其离场前的信息判断其当时是否位于本卡连接区内。
function c1948619.setcfilter(c,tp,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0x8) and c:IsFaceup() and c:IsControler(tp) and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0x8) and c:IsPreviousPosition(POS_FACEUP)
			and c:IsPreviousControler(tp) and bit.extract(ec:GetLinkedZone(tp),c:GetPreviousSequence())~=0
	end
end
-- 效果①的发动条件：当有「英雄」怪兽召唤·特殊召唤成功时，检查这些怪兽中是否存在满足setcfilter（即在自己场上且位于本卡连接区）的怪兽；存在则条件成立。
function c1948619.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1948619.setcfilter,1,nil,tp,e:GetHandler())
end
-- 对象选择过滤：从墓地选出的卡须为「融合」魔法卡或「变化」速攻魔法卡，且该卡当前可以盖放到场上（满足SSetable）。
function c1948619.setfilter(c)
	return ((c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)) or (c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0xa5))) and c:IsSSetable()
end
-- 效果①的发动时处理：确认对象合法性后，让发动者选择自己墓地1张符合条件的「融合」魔法卡或「变化」速攻魔法卡作为对象，并登记“使该卡离开墓地”的操作信息。
function c1948619.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1948619.setfilter(chkc) end
	if chk==0 then return true end
	-- 向发动者显示“请选择要盖放的卡”的选择提示，供随后的墓地对象选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地的满足setfilter的卡中选择1张作为效果对象，并将其登记为本连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c1948619.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次效果的操作信息：会使1张卡从墓地离开（涉及墓地效果，用于配合「王家长眠之谷」等卡的判定）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果①的解决处理：取得对象卡，若对象卡仍与效果有关联，则将其盖放到自己场上。
function c1948619.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①发动时选择的对象卡（墓地中的那张魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象魔法卡以里侧表示盖放到己方的魔法与陷阱区域（即“在自己场上盖放”）。
		Duel.SSet(tp,tc)
	end
end
-- 效果②的发动条件：这张卡被战斗破坏送去墓地，或被对方的效果破坏送去墓地（且破坏前由自己控制）时，可以发动。
function c1948619.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 特殊召唤的过滤条件：手牌中的卡必须是「英雄」怪兽，并且能够被当前效果特殊召唤（通过召唤条件及苏生限制检查）。
function c1948619.spfilter(c,e,tp)
	return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动合法性检查：己方主要怪兽区有空位，并且手牌中存在至少1只满足spfilter的「英雄」怪兽，才能发动。
function c1948619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否还有空位（没有空位则效果不能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只「英雄」怪兽满足特殊召唤条件；与上一个条件同时满足时允许发动。
		and Duel.IsExistingMatchingCard(c1948619.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记效果②的操作信息：本效果将进行特殊召唤，预计从手牌把1只怪兽特殊召唤到己方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的解决处理：若己方主要怪兽区有空位，则从手牌选择1只「英雄」怪兽，以表侧表示特殊召唤到己方场上。
function c1948619.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区有空位；若没有空位则直接结束处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动者显示“请选择要特殊召唤的卡”的选择提示，供随后的手牌选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足spfilter的「英雄」怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c1948619.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「英雄」怪兽以表侧表示特殊召唤到己方场上（使用通常召唤手续并检查召唤条件/苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
