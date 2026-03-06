--HSRコルク－10
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是风属性怪兽不能特殊召唤。
-- ①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。
-- ●从卡组把1张「疾行机人」魔法·陷阱卡加入手卡。
-- ●这张卡只用「疾行机人」怪兽为素材作同调召唤的场合，若那次同调召唤使用过的一组同调素材怪兽全部在自己墓地齐集，那一组特殊召唤。
function c23361526.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23361526,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,23361526)
	e1:SetCondition(c23361526.condition)
	e1:SetCost(c23361526.cost)
	e1:SetTarget(c23361526.target)
	e1:SetOperation(c23361526.operation)
	c:RegisterEffect(e1)
	-- ●从卡组把1张「疾行机人」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c23361526.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在该回合特殊召唤的次数
	Duel.AddCustomActivityCounter(23361526,ACTIVITY_SPSUMMON,c23361526.counterfilter)
end
-- 计数器的过滤函数，只有风属性的怪兽才能计入计数
function c23361526.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
-- 判断该卡是否为同调召唤成功
function c23361526.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置发动效果的费用，确保该回合只能发动一次
function c23361526.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合是否已经发动过一次同调召唤效果
	if chk==0 then return Duel.GetCustomActivityCount(23361526,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个场地方效果，禁止该玩家在本回合特殊召唤非风属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23361526.splimit)
	-- 将费用效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 该函数用于判断是否禁止特殊召唤非风属性怪兽
function c23361526.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤函数，用于检索卡组中「疾行机人」魔法·陷阱卡
function c23361526.thfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤函数，用于判断墓地中的怪兽是否为本次同调召唤的素材
function c23361526.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动目标，根据选择的效果决定处理方式
function c23361526.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=mg:GetCount()
	-- 检测卡组中是否存在满足条件的「疾行机人」魔法·陷阱卡
	local b1=Duel.IsExistingMatchingCard(c23361526.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=e:GetLabel()==1 and ct>0 and mg:FilterCount(c23361526.spfilter,nil,e,tp,c)==ct
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and not Duel.IsPlayerAffectedByEffect(tp,59822133)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops,opval={},{}
	if b1 then
		ops[off]=aux.Stringid(23361526,1)  --"卡组检索"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(23361526,2)  --"特殊召唤素材"
		opval[off]=1
		off=off+1
	end
	-- 让玩家选择发动的效果
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置操作信息，表示将从卡组检索1张魔法·陷阱卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息，表示将目标怪兽特殊召唤
		Duel.SetTargetCard(mg)
		-- 设置操作信息，表示将目标怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
	end
end
-- 执行效果处理，根据选择的效果进行对应操作
function c23361526.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张满足条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c23361526.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		-- 获取当前连锁中设定的目标卡组
		local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=mg:Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()<mg:GetCount() then return end
		-- 检查场上是否有足够的位置进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
		-- 将目标卡组特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断怪兽是否不属于「疾行机人」系列
function c23361526.mfilter(c)
	return not c:IsSetCard(0x2016)
end
-- 检查本次同调召唤所用的素材是否全部在墓地齐集
function c23361526.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c23361526.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
