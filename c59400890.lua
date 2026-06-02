--滅びの黒魔術師
-- 效果：
-- 「黑魔术师」＋光·暗属性怪兽
-- 「毁灭之黑魔术师」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●魔法卡的效果发动的回合，把自己场上1只6星以上的魔法师族·暗属性怪兽除外的场合可以从额外卡组特殊召唤。
-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
-- ②：这张卡特殊召唤的场合才能发动。把1只「黑魔术师」或者1张有那个卡名记述的卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册复活限制、融合召唤手续、特殊召唤成功登记标记、特殊召唤规则、特召限制、卡名变更以及特召成功时的检索效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材需求：卡名作为「黑魔术师」的怪兽 + 1只光或暗属性怪兽
	aux.AddFusionProcCodeFun(c,46986414,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK),1,true,true)
	-- 「毁灭之黑魔术师」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- ●魔法卡的效果发动的回合，把自己场上1只6星以上的魔法师族·暗属性怪兽除外的场合可以从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 「毁灭之黑魔术师」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
	aux.EnableChangeCode(c,46986414,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡特殊召唤的场合才能发动。把1只「黑魔术师」或者1张有那个卡名记述的卡从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 添加自定义动作计数器，用于统计双方玩家发动魔法卡效果的次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数：排除魔法卡的效果发动（即如果是魔法卡发动则返回false，让计数器增加）
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL)
end
-- 过滤函数：用于特殊召唤的场上素材需为6星以上的魔法师族·暗属性怪兽，且可以被除外
function s.spfilter(c,tp,sc)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(6)
		-- 检查怪兽是否可以作为特殊召唤的Cost被除外，以及除外该卡后是否可以在额外怪兽区/主怪兽区特殊召唤该卡
		and c:IsAbleToRemoveAsCost() and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 自身特召规则的发动条件：自己墓地/场上有可除外怪兽，本回合玩家未特召过该卡，且本回合有魔法卡的效果发动
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在符合特殊召唤素材条件的怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
		-- 检查当前回合发动效果的玩家是否尚未特殊召唤过该卡
		and Duel.GetFlagEffect(tp,id)==0
		-- 检查自己本回合是否有魔法卡的效果发动
		and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0
		-- 检查对方本回合是否有魔法卡的效果发动
		or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0)
end
-- 自身特召规则的目标选择：让玩家选择场上1只符合条件的怪兽，并保存为标签对象以备后续除外使用
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有符合特殊召唤素材条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp,c)
	-- 提示玩家选择作为特殊召唤素材要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 自身特召规则的效果处理：给自身注册本回合已特召的标记，并将选择的素材怪兽除外
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 将作为特殊召唤素材的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 特殊召唤成功登记的条件判定：这张卡是以融合召唤方式召唤，或者因自身规则特召成功
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 特殊召唤成功登记的执行函数：为特召玩家注册本回合已特召过该卡的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册已特殊召唤过该卡的全局标记效果（持续到回合结束）
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 特召限制的判定函数：除融合召唤外不能特殊召唤，且每回合只能特殊召唤1次
function s.splimit(e,se,sp,st)
	-- 检查特殊召唤方式是否为融合召唤，且玩家本回合未特殊召唤过该卡
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 过滤函数：检索可以加入手牌的「黑魔术师」或记述有「黑魔术师」卡名的卡片
function s.thfilter(c)
	-- 检查卡片是否可以加入手卡，并且自身卡名为「黑魔术师」或卡名记述中包含「黑魔术师」
	return c:IsAbleToHand() and aux.IsCodeOrListed(c,46986414)
end
-- 效果②的检索发动准备：检查卡组是否存在符合条件的卡片，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张符合条件的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的检索效果处理：从卡组选择1张符合条件的卡片加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家在卡组中选择1张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入到玩家的手牌中
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

