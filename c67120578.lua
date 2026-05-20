--ガガガヘッド
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以不用解放并作为4星怪兽召唤。
-- ②：这张卡召唤成功时，以「我我我首领」以外的自己墓地最多2只「我我我」怪兽为对象才能发动。那些怪兽特殊召唤。这个回合自己不能作除只用「我我我」怪兽为素材的超量召唤以外的特殊召唤。
-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
function c67120578.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以不用解放并作为4星怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67120578,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c67120578.ntcon)
	e1:SetOperation(c67120578.ntop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时，以「我我我首领」以外的自己墓地最多2只「我我我」怪兽为对象才能发动。那些怪兽特殊召唤。这个回合自己不能作除只用「我我我」怪兽为素材的超量召唤以外的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67120578,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c67120578.sptg)
	e2:SetOperation(c67120578.spop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c67120578.efcon)
	e3:SetOperation(c67120578.efop)
	c:RegisterEffect(e3)
end
-- 判定是否满足不用解放进行召唤的条件：对方场上有怪兽存在，自己场上没有怪兽存在
function c67120578.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定召唤不需要解放，且自己场上有可用的怪兽区域
	return minc==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定对方场上有怪兽存在
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 判定自己场上没有怪兽存在
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 不用解放进行召唤时的处理：注册使这张卡等级变成4星的效果
function c67120578.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 作为4星怪兽召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中「我我我首领」以外的「我我我」怪兽
function c67120578.spfilter(c,e,tp)
	return c:IsSetCard(0x54) and not c:IsCode(67120578) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备：检测怪兽区域空格、墓地中是否存在合法目标，并选择对象
function c67120578.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67120578.spfilter(chkc,e,tp) end
	-- 在效果发动阶段，检测自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动阶段，检测自己墓地是否存在至少1只符合条件的「我我我」怪兽
		and Duel.IsExistingTarget(c67120578.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 计算最多可以特殊召唤的怪兽数量（不超过2只且不超过空余怪兽区域数）
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1到ct只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c67120578.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 特殊召唤效果的处理：特殊召唤对象怪兽，并注册本回合的特殊召唤限制
function c67120578.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	local ct=g:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		-- 将符合条件的卡片以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local c=e:GetHandler()
	-- 这个回合自己不能作除只用「我我我」怪兽为素材的超量召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c67120578.splimit)
	-- 注册限制玩家本回合不能进行超量召唤以外的特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	-- 只用「我我我」怪兽为素材的超量召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetTargetRange(0x7f,0x7f)
	e2:SetTarget(c67120578.splimtg_target)
	e2:SetValue(c67120578.splimtg_value)
	e2:SetOwnerPlayer(tp)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家本回合不能将「我我我」以外的怪兽作为超量素材的效果
	Duel.RegisterEffect(e2,tp)
	-- 这个回合自己不能作除只用「我我我」怪兽为素材的超量召唤以外的特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(67120578)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册本回合已发动过此效果的标记
	Duel.RegisterEffect(e3,tp)
end
-- 过滤非「我我我」怪兽
function c67120578.splimtg_target(e,c)
	return not c:IsSetCard(0x54)
end
-- 判定怪兽是否属于发动效果的玩家
function c67120578.splimtg_value(e,c)
	if not c then return false end
	return c:GetControler()==e:GetOwnerPlayer()
end
-- 判定特殊召唤类型是否不为超量召唤
function c67120578.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype~=SUMMON_TYPE_XYZ
end
-- 判定是否作为超量素材送去墓地
function c67120578.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 作为超量素材时的处理：赋予超量召唤成功的怪兽抽卡的效果
function c67120578.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(67120578,2))  --"抽1张卡（我我我首领）"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c67120578.drcon)
	e1:SetTarget(c67120578.drtg)
	e1:SetOperation(c67120578.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 得到以下效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判定该怪兽是否成功进行了超量召唤
function c67120578.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 抽卡效果的发动准备：设置抽卡玩家和抽卡数量
function c67120578.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了抽卡效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置效果处理信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理：执行抽卡
function c67120578.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
