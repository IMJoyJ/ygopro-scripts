--HSRコルク－10
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是风属性怪兽不能特殊召唤。
-- ①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。
-- ●从卡组把1张「疾行机人」魔法·陷阱卡加入手卡。
-- ●这张卡只用「疾行机人」怪兽为素材作同调召唤的场合，若那次同调召唤使用过的一组同调素材怪兽全部在自己墓地齐集，那一组特殊召唤。
function c23361526.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是风属性怪兽不能特殊召唤。①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。
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
	-- 这张卡只用「疾行机人」怪兽为素材作同调召唤的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c23361526.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 注册特殊召唤非风属性怪兽的计数器
	Duel.AddCustomActivityCounter(23361526,ACTIVITY_SPSUMMON,c23361526.counterfilter)
end
-- 计数器过滤函数：检查特殊召唤的怪兽是否为风属性
function c23361526.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup()
end
-- 发动条件：这张卡同调召唤成功
function c23361526.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 代价与誓约：检查本回合是否特殊召唤过非风属性怪兽，并注册本回合不能特殊召唤非风属性怪兽的誓约效果
function c23361526.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查本回合自己是否未特殊召唤过风属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(23361526,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是风属性怪兽不能特殊召唤。①：这张卡同调召唤成功的场合，可以从以下效果选择1个发动。●从卡组把1张「疾行机人」魔法·陷阱卡加入手卡。●这张卡只用「疾行机人」怪兽为素材作同调召唤的场合，若那次同调召唤使用过的一组同调素材怪兽全部在自己墓地齐集，那一组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c23361526.splimit)
	-- 向玩家注册誓约效果：本回合自己不是风属性怪兽不能特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：不能特殊召唤风属性以外的怪兽
function c23361526.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤卡组中的「疾行机人」魔法·陷阱卡
function c23361526.thfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤作为该次同调召唤素材且在墓地中可以特殊召唤的怪兽
function c23361526.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测：根据满足条件的分支效果，让玩家选择发动的效果并设置操作信息
function c23361526.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=mg:GetCount()
	-- 检查卡组中是否存在「疾行机人」魔法·陷阱卡
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
	-- 让玩家选择要发动的效果分支
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置操作信息：从卡组把1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 把同调素材怪兽设为当前连锁的效果处理对象
		Duel.SetTargetCard(mg)
		-- 设置操作信息：将同调素材怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
	end
end
-- 效果处理的执行：根据选择的分支，执行检索卡片或特殊召唤素材怪兽的操作
function c23361526.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家选择卡组中1张满足条件的「疾行机人」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c23361526.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		-- 获取作为本效果对象的同调素材怪兽
		local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=mg:Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()<mg:GetCount() then return end
		-- 检查自己场上的怪兽区域空位数是否足够容纳要特殊召唤的怪兽数量，若不足则不处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
		-- 将那一组同调素材怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤非「疾行机人」怪兽
function c23361526.mfilter(c)
	return not c:IsSetCard(0x2016)
end
-- 在同调召唤成功时检查素材，若使用的同调素材怪兽全部是「疾行机人」怪兽，则将标记设为1，否则为0
function c23361526.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c23361526.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
