--冷える火
-- 效果：
-- ①：自己或对方的基本分回复的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，这张卡在怪兽区域存在的状态，自己或对方的基本分回复的场合才能发动。自己或对方的基本分回复1000。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（手卡特召）和②效果（回复1000LP）
function s.initial_effect(c)
	-- ①：自己或对方的基本分回复的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RECOVER)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡在怪兽区域存在的状态，自己或对方的基本分回复的场合才能发动。自己或对方的基本分回复1000。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetTarget(s.remtg)
	e2:SetOperation(s.remop)
	c:RegisterEffect(e2)
end
-- ①效果（手卡特召）的发动检测与效果对象确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，确认自己场上有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤自身1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果（手卡特召）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果（回复1000LP）的发动检测与效果对象确认
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：有玩家回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
-- ②效果（回复1000LP）的效果处理函数
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local p=tp
	-- 询问玩家是否让对方回复基本分，若选择“否”则由自己回复
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then p=1-tp end  --"是否让对方回复基本分？"
	-- 使选定的玩家回复1000基本分
	Duel.Recover(p,1000,REASON_EFFECT)
end
