--ディーヴジャン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的表侧表示的「分裂机器人」全部解放才能发动。把最多有解放数量×2只的「机械衍生物」（机械族·炎·1星·攻/守200）在自己场上特殊召唤。这衍生物被破坏时对方受到每1只500伤害。
-- ②：这张卡被除外的场合，以自己场上的衍生物任意数量为对象才能发动。那衍生物破坏。
function c42427230.initial_effect(c)
	-- ①：把自己场上的表侧表示的「分裂机器人」全部解放才能发动。把最多有解放数量×2只的「机械衍生物」（机械族·炎·1星·攻/守200）在自己场上特殊召唤。这衍生物被破坏时对方受到每1只500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42427230,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,42427230)
	e1:SetCost(c42427230.spcost)
	e1:SetTarget(c42427230.sptg)
	e1:SetOperation(c42427230.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以自己场上的衍生物任意数量为对象才能发动。那衍生物破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42427230,1))  --"破坏衍生物"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,42427231)
	e2:SetTarget(c42427230.destg)
	e2:SetOperation(c42427230.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，返回场上自己控制或表侧表示的「分裂机器人」
function c42427230.cfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsCode(42427230)
end
-- 判断是否满足①效果的解放条件，即场上自己控制或表侧表示的「分裂机器人」全部可以解放且有怪兽区空位
function c42427230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上自己控制或表侧表示的「分裂机器人」
	local rg=Duel.GetMatchingGroup(c42427230.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return rg:GetCount()==rg:FilterCount(Card.IsReleasable,nil)
		-- 判断场上自己控制或表侧表示的「分裂机器人」全部可以解放且有怪兽区空位
		and rg:GetCount()~=0 and Duel.GetMZoneCount(tp,rg)>0 end
	-- 将场上自己控制或表侧表示的「分裂机器人」全部解放，并将解放数量乘以2作为特殊召唤衍生物的数量
	local ct=Duel.Release(rg,REASON_COST)*2
	e:SetLabel(ct)
end
-- 判断是否可以特殊召唤衍生物
function c42427230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以特殊召唤衍生物
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,42427231,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_FIRE) end
	-- 设置操作信息，表示将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理①效果的特殊召唤操作，包括判断召唤数量、处理青眼精灵龙限制、选择召唤数量、创建并特殊召唤衍生物
function c42427230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=e:GetLabel()
	-- 判断是否可以特殊召唤衍生物
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,42427231,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_FIRE) then
		local count=math.min(ft,ct)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			-- 提示玩家选择要特殊召唤的衍生物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(42427230,2))  --"请选择要特殊召唤的衍生物数量"
			-- 让玩家宣言要特殊召唤的衍生物数量
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		for i=1,count do
			-- 创建一个「机械衍生物」
			local token=Duel.CreateToken(tp,42427231)
			-- 特殊召唤一个衍生物
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				-- 为特殊召唤的衍生物添加效果，当衍生物被破坏时，对方受到每1只500伤害
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(42427230,3))
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_LEAVE_FIELD)
				e1:SetLabel(tp)
				e1:SetOperation(c42427230.damop)
				token:RegisterEffect(e1,true)
			end
		end
		-- 完成特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
-- 处理衍生物被破坏时的伤害效果
function c42427230.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetLabel()
	if c:IsReason(REASON_DESTROY) then
		-- 给对方造成每只衍生物500点伤害
		Duel.Damage(1-p,500,REASON_EFFECT)
	end
	e:Reset()
end
-- 过滤函数，返回场上表侧表示的衍生物
function c42427230.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOKEN)
end
-- 过滤函数，返回场上表侧表示且可以成为效果对象的衍生物
function c42427230.desfilter2(c,e)
	return c42427230.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 设置②效果的目标选择，选择场上自己控制的衍生物
function c42427230.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c42427230.desfilter(chkc) end
	-- 获取场上自己控制的衍生物
	local g=Duel.GetMatchingGroup(c42427230.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:GetCount()~=0 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:Select(tp,1,g:GetCount(),nil)
	-- 设置当前处理的连锁的对象为选择的衍生物
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示将要破坏衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 处理②效果的破坏操作，将目标衍生物破坏
function c42427230.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 将目标衍生物破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
