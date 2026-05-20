--R－ACEファイア・アタッカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「救援ACE队 空中灭火机」以外的「救援ACE队」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：抽卡以外的方法让对方手卡有卡加入的场合才能发动。自己抽2张。那之后，选自己1张手卡丢弃。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手卡特召，分为召唤和特召两个触发事件）与②效果（对方检索/回收时抽2丢1）。
function s.initial_effect(c)
	-- ①：自己场上有「救援ACE队 空中灭火机」以外的「救援ACE队」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：抽卡以外的方法让对方手卡有卡加入的场合才能发动。自己抽2张。那之后，选自己1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的、「救援ACE队 空中灭火机」以外的「救援ACE队」怪兽。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
		and c:IsSetCard(0x18b) and not c:IsCode(id)
end
-- ①效果的发动条件：自己场上有满足过滤条件的怪兽召唤·特殊召唤的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若此卡仍在手卡，则将其在自己场上表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：对方手卡中因抽卡以外的方法加入的卡。
function s.drfilter(c,tp)
	return c:IsControler(1-tp) and not c:IsReason(REASON_DRAW)
end
-- ②效果的发动条件：对方手卡有满足过滤条件的卡加入的场合。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drfilter,1,nil,tp)
end
-- ②效果的发动准备：检查自己是否能抽卡，设置效果对象为自己，并设置抽卡和丢弃手卡的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以效果抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2（抽卡张数）。
	Duel.SetTargetParam(2)
	-- 设置操作信息：自己抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息：自己丢弃1张手卡。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- ②效果的处理：自己抽2张卡，洗牌，然后选自己1张手卡丢弃。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 尝试让目标玩家因效果抽2张卡，若成功抽到2张则继续处理。
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 洗切目标玩家的手卡。
		Duel.ShuffleHand(p)
		-- 中断当前效果，使后续的丢弃手卡处理与抽卡不视为同时进行。
		Duel.BreakEffect()
		-- 让目标玩家选择自己1张手卡因效果丢弃。
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
