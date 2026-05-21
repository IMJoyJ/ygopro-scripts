--トリガー・ヴルム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡作为暗属性连接怪兽的连接素材送去墓地的场合才能发动。墓地的这张卡在作为那只连接怪兽所连接区的自己场上攻击表示特殊召唤。这个效果特殊召唤的这张卡不能作为连接素材。
-- ②：这张卡被连接怪兽的所发动的效果所破坏的场合或者所除外的场合发动。自己从卡组抽1张。
function c95504778.initial_effect(c)
	-- ①：这张卡作为暗属性连接怪兽的连接素材送去墓地的场合才能发动。墓地的这张卡在作为那只连接怪兽所连接区的自己场上攻击表示特殊召唤。这个效果特殊召唤的这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95504778,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,95504778)
	e1:SetCondition(c95504778.spcon)
	e1:SetTarget(c95504778.sptg)
	e1:SetOperation(c95504778.spop)
	c:RegisterEffect(e1)
	-- 建立作为素材的卡片与因其召唤出的连接怪兽之间的关系，以便后续获取该连接怪兽
	aux.CreateMaterialReasonCardRelation(c,e1)
	-- ②：这张卡被连接怪兽的所发动的效果所破坏的场合或者所除外的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95504778,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,95504779)
	e2:SetCondition(c95504778.drcon)
	e2:SetTarget(c95504778.drtg)
	e2:SetOperation(c95504778.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 验证这张卡是否作为暗属性连接怪兽的连接素材送去墓地
function c95504778.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 特殊召唤效果的发动合法性检测，并获取可特殊召唤的区域
function c95504778.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if chk==0 then
		local zone=bit.band(rc:GetLinkedZone(tp),0x1f)
		-- 检查作为连接素材召唤出的连接怪兽是否在场，以及自己场上是否有可用的怪兽区域
		return rc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,tp,zone)
	end
	-- 将作为连接素材召唤出的连接怪兽设为效果处理的对象
	Duel.SetTargetCard(rc)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的具体处理，并在特殊召唤成功时施加不能作为连接素材的限制
function c95504778.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为连接素材召唤出的连接怪兽
	local rc=Duel.GetFirstTarget()
	if not rc:IsRelateToChain() then return end
	local zone=bit.band(rc:GetLinkedZone(tp),0x1f)
	-- 如果这张卡仍存在于墓地，且连接怪兽所连接的区域有空位，则将这张卡在那些区域以表侧攻击表示特殊召唤
	if c:IsRelateToEffect(e) and zone~=0 and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_ATTACK,zone) then
		-- 这个效果特殊召唤的这张卡不能作为连接素材。②：这张卡被连接怪兽的所发动的效果所破坏的场合或者所除外的场合发动。自己从卡组抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 验证这张卡是否被连接怪兽发动的效果破坏或除外
function c95504778.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re:IsActiveType(TYPE_LINK) and re:IsActivated()
end
-- 抽卡效果的发动合法性检测
function c95504778.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将抽卡的操作对象设为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的具体处理
function c95504778.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
