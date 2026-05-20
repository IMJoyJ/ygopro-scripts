--ノクトビジョン・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有龙族·暗属性怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为连接素材送去墓地的场合才能发动。自己抽1张。
-- ③：自己场上的里侧表示卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把墓地的这张卡除外才能发动。那个效果无效。这个回合，对方不能把那些里侧表示卡作为效果的对象。
function c70333910.initial_effect(c)
	-- ①：自己场上有龙族·暗属性怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70333910,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,70333910)
	e1:SetCondition(c70333910.spcon)
	e1:SetTarget(c70333910.sptg)
	e1:SetOperation(c70333910.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70333910,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,70333911)
	e2:SetCondition(c70333910.drcon)
	e2:SetTarget(c70333910.drtg)
	e2:SetOperation(c70333910.drop)
	c:RegisterEffect(e2)
	-- ③：自己场上的里侧表示卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把墓地的这张卡除外才能发动。那个效果无效。这个回合，对方不能把那些里侧表示卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70333910,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c70333910.discon)
	-- 设置把墓地的这张卡除外作为发动的Cost
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(c70333910.disop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的龙族·暗属性怪兽
function c70333910.spfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp)
end
-- 检查特殊召唤成功的怪兽中是否存在自己场上的龙族·暗属性怪兽，且不包含这张卡自身
function c70333910.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c70333910.spfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果①的发动准备与检测，确认怪兽区域有空位且这张卡可以特殊召唤，并设置特殊召唤的操作信息
function c70333910.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤手牌的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理，若这张卡仍存在于手牌，则将其特殊召唤
function c70333910.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否作为连接素材送去墓地
function c70333910.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 效果②的发动准备与检测，确认玩家是否可以抽卡，并设置抽卡的对象玩家、张数及操作信息
function c70333910.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的处理，获取目标玩家和抽卡张数并执行抽卡
function c70333910.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤自己场上里侧表示的卡
function c70333910.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsFacedown()
end
-- 效果③的发动条件检测，确认是对方发动的取对象效果，且对象中包含自己场上的里侧表示卡，且该效果可以被无效
function c70333910.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象卡片组中存在自己场上的里侧表示卡，且该连锁效果可以被无效
	return tg and tg:IsExists(c70333910.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果③的处理，无效对方的效果，并给那些作为对象的里侧表示卡添加“本回合不能被对方作为效果对象”的效果
function c70333910.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效对方发动的效果
	Duel.NegateEffect(ev)
	-- 获取对方效果的对象中，当前仍为里侧表示且与该效果有关联的卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(Card.IsFacedown,nil):Filter(Card.IsRelateToEffect,nil,re)
	local tc=tg:GetFirst()
	while tc do
		-- 这个回合，对方不能把那些里侧表示卡作为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetValue(c70333910.tgoval)
		e1:SetCondition(c70333910.tgocon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end
-- 限制不能成为对方（发动该保护效果的玩家的对手）的效果对象
function c70333910.tgoval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
-- 限制该保护效果仅在卡片处于里侧表示时适用
function c70333910.tgocon(e)
	return e:GetHandler():IsFacedown()
end
