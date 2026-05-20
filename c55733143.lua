--ミミグル・チャーム
-- 效果：
-- 这个卡名的①的效果1回合可以使用最多2次。
-- ①：对方场上的「迷拟宝箱鬼」怪兽在主要阶段反转的场合才能发动（同一连锁上最多1次）。对方的额外卡组的里侧的卡随机选1张。那张卡是可以特殊召唤的怪兽的场合，那只怪兽在自己场上特殊召唤。不是的场合或者不能特殊召唤的场合，那张卡除外。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
local s,id,o=GetID()
-- 注册卡片的发动效果以及在场上时的诱发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合可以使用最多2次。①：对方场上的「迷拟宝箱鬼」怪兽在主要阶段反转的场合才能发动（同一连锁上最多1次）。对方的额外卡组的里侧的卡随机选1张。那张卡是可以特殊召唤的怪兽的场合，那只怪兽在自己场上特殊召唤。不是的场合或者不能特殊召唤的场合，那张卡除外。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"确认额外卡组"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(2,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：对方场上的「迷拟宝箱鬼」怪兽从里侧表示变为表侧表示（反转）。
function s.cfilter2(c,tp)
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup() and c:IsControler(1-tp) and c:IsSetCard(0x1b7)
end
-- 效果发动条件：主要阶段中，对方场上有「迷拟宝箱鬼」怪兽反转。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有满足条件的怪兽反转，且当前处于主要阶段1或主要阶段2。
	return eg:IsExists(s.cfilter2,1,nil,tp) and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤条件：对方额外卡组里侧表示且可以被除外的卡。
function s.spfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果发动准备：检查对方额外卡组是否有里侧表示的卡，设置特殊召唤的操作信息，并给自身注册同一连锁上最多发动1次的标记。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否存在里侧表示的卡，且该效果在同一连锁上尚未发动过。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_EXTRA,1,nil) and e:GetHandler():GetFlagEffect(id)==0 end
	-- 设置操作信息：从额外卡组将1张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
-- 效果处理：洗切对方额外卡组并随机选1张确认，若能特殊召唤则在自己场上特殊召唤并使其本回合不能发动效果，否则将其除外。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组所有里侧表示的卡。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
	if #g==0 then return end
	-- 洗切对方的额外卡组。
	Duel.ShuffleExtra(1-tp)
	local tg=g:RandomSelect(1-tp,1)
	-- 让己方玩家确认随机选出的那张卡。
	Duel.ConfirmCards(tp,tg)
	local tc=tg:GetFirst()
	-- 判断该卡是否可以特殊召唤且自己场上有可用位置，并尝试将其在自己场上表侧表示特殊召唤。
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		-- 将该卡表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
