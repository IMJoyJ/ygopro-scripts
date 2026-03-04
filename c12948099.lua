--古神クトグア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。场上的4阶超量怪兽全部回到持有者的额外卡组。
-- ②：这张卡为素材的融合召唤成功的场合发动。自己从卡组抽1张。
-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
function c12948099.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。场上的4阶超量怪兽全部回到持有者的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12948099,0))  --"回到持有者的额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12948099.tdcon)
	e1:SetTarget(c12948099.tdtg)
	e1:SetOperation(c12948099.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡为素材的融合召唤成功的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12948099,1))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c12948099.drcon)
	e2:SetTarget(c12948099.drtg)
	e2:SetOperation(c12948099.drop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这次超量召唤成功的场合发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c12948099.efcon)
	e3:SetOperation(c12948099.efop)
	c:RegisterEffect(e3)
end
-- 判断是否为同调召唤成功
function c12948099.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的4阶超量怪兽
function c12948099.filter(c)
	return c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsAbleToExtra()
end
-- 设置效果目标，检查场上是否存在满足条件的4阶超量怪兽
function c12948099.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的4阶超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12948099.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足条件的4阶超量怪兽组
	local g=Duel.GetMatchingGroup(c12948099.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,g:GetCount(),0,0)
end
-- 执行效果操作，将满足条件的怪兽送回额外卡组
function c12948099.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的4阶超量怪兽组
	local g=Duel.GetMatchingGroup(c12948099.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将怪兽送回卡组顶端
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 判断是否为融合召唤作为素材
function c12948099.drcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION
end
-- 设置抽卡效果目标
function c12948099.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，指定抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果操作
function c12948099.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断是否为超量召唤作为素材
function c12948099.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 执行效果操作，为超量召唤的怪兽添加抽卡效果
function c12948099.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为超量召唤的怪兽添加抽卡效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(12948099,2))  --"抽1张卡（古神 克图格亚）"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12948099.drcon2)
	e1:SetTarget(c12948099.drtg2)
	e1:SetOperation(c12948099.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 为超量召唤的怪兽添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断是否为超量召唤成功
function c12948099.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置超量召唤成功后的抽卡效果目标
function c12948099.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，指定抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
