--滅びの黒魔術師
-- 效果：
-- 「黑魔术师」＋光·暗属性怪兽
-- 「毁灭之黑魔术师」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●魔法卡的效果发动的回合，把自己场上1只6星以上的魔法师族·暗属性怪兽除外的场合可以从额外卡组特殊召唤。
-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
-- ②：这张卡特殊召唤的场合才能发动。把1只「黑魔术师」或者1张有那个卡名记述的卡从卡组加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、特殊召唤规则、特殊召唤限制、卡名变更、特殊召唤成功时的诱发效果，以及魔法卡发动计数器
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「黑魔术师」加1只光·暗属性怪兽
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
	-- 使这张卡在场上·墓地存在时卡名当作「黑魔术师」使用
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
	-- 注册自定义活动计数器，用于检测是否有魔法卡的效果发动
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数，用于计数器排除非魔法卡的效果发动（即只统计魔法卡的效果发动）
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL)
end
-- 过滤自己场上用于特殊召唤此卡的6星以上魔法师族·暗属性怪兽
function s.spfilter(c,tp,sc)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(6)
		-- 检查该怪兽是否能作为Cost除外，且除外该怪兽后额外卡组怪兽出场的可用区域是否大于0
		and c:IsAbleToRemoveAsCost() and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 自身特殊召唤规则的条件函数，检查场上是否有可除外的怪兽、本回合是否未特殊召唤过此卡，且本回合有魔法卡的效果发动
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足条件的6星以上魔法师族·暗属性怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
		-- 检查本回合该玩家是否尚未特殊召唤过「毁灭之黑魔术师」
		and Duel.GetFlagEffect(tp,id)==0
		-- 检查自己本回合是否有魔法卡的效果发动
		and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0
		-- 或者对方本回合是否有魔法卡的效果发动
		or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0)
end
-- 自身特殊召唤规则的素材选择函数，让玩家选择1只满足条件的怪兽并将其记录在效果对象中
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤除外条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp,c)
	-- 向玩家发送提示信息，要求选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 自身特殊召唤规则的执行函数，给自身注册本回合已特殊召唤的标记，并将选中的怪兽除外
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 检查此卡是否是通过融合召唤特殊召唤，或者是否通过自身规则特殊召唤（带有对应标记）
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 注册玩家本回合已特殊召唤过此卡的全局标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册本回合已特殊召唤过此卡的全局标记，持续到回合结束
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤限制条件函数，限制此卡只能通过融合召唤或在未注册特殊召唤标记时通过自身规则特殊召唤
function s.splimit(e,se,sp,st)
	-- 限制特殊召唤方式必须为融合召唤，且该玩家本回合尚未特殊召唤过此卡
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 过滤卡组中可以加入手卡的「黑魔术师」或记述了「黑魔术师」卡名的卡
function s.thfilter(c)
	-- 检查卡片是否能加入手卡，且卡名是「黑魔术师」或记述了「黑魔术师」卡名
	return c:IsAbleToHand() and aux.IsCodeOrListed(c,46986414)
end
-- 检索效果的靶向/启动检查函数，确认卡组中存在可检索卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段（chk==0）检查卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示此效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数，让玩家从卡组选择1张满足条件的卡加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

