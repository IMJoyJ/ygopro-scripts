--幻炎の剣士－ミラージュ・ソードマン－
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的炎属性融合怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那2只进行战斗的怪兽破坏。
-- ③：这张卡被战斗或者其他卡的效果破坏的场合才能发动。7星以下的1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册该卡的效果文本中记述了卡号为45231177（炎之剑士）的卡片。
	aux.AddCodeList(c,45231177)
	-- 注册一个用于检测这张卡是否已在墓地的状态标记效果，以确保从墓地发动效果时的合法性。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己场上的表侧表示的炎属性融合怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤自身"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetLabelObject(e0)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那2只进行战斗的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏双方怪兽"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗或者其他卡的效果破坏的场合才能发动。7星以下的1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤「炎之剑士」或者有那个卡名记述的怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上的表侧表示的、非魔陷区离场的炎属性融合怪兽被战斗或效果破坏。
function s.cfilter(c,tp,se)
	return c:IsPreviousControler(tp) and not c:IsPreviousLocation(LOCATION_SZONE) and c:GetOriginalAttribute()==ATTRIBUTE_FIRE and c:IsType(TYPE_FUSION)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果①的发动条件：检查被破坏的怪兽中是否存在满足条件的炎属性融合怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	if c:IsLocation(LOCATION_HAND) then se=nil end
	return eg:IsExists(s.cfilter,1,c,tp,se)
end
-- 效果①的特殊召唤发动准备与合法性检测。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的特殊召唤效果处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的破坏效果发动准备与合法性检测。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前进行攻击的怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则将目标设为被攻击的怪兽（即对方怪兽）。
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 设置连锁处理的操作信息：破坏进行战斗的这2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(c,tc),1,0,0)
end
-- 效果②的破坏效果处理。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToBattle() and tc:IsRelateToBattle() then
		-- 因效果破坏进行战斗的这2只怪兽。
		Duel.Destroy(Group.FromCards(c,tc),REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡被战斗或效果破坏，且未在同一连锁中发动过效果②。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():GetFlagEffect(id)==0
end
-- 过滤条件：7星以下、卡名为「炎之剑士」或记述了「炎之剑士」卡名的怪兽，且能被特殊召唤。
function s.spfilter(c,e,tp)
	-- 检查卡片是否为7星以下且卡名为「炎之剑士」或记述了「炎之剑士」卡名。
	return (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsLevelBelow(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 如果卡片在卡组，检查自己场上是否有空余的怪兽区域。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 如果卡片在额外卡组，检查是否有空余的额外怪兽区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果③的特殊召唤发动准备与合法性检测。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组或额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果③的特殊召唤效果处理。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
