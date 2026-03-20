--魔轟神ディアネイラ
-- 效果：
-- 这张卡可以把1只「魔轰神」怪兽解放表侧攻击表示上级召唤。
-- ①：只要这张卡在怪兽区域存在，对方把通常魔法卡发动的场合，1回合只有1次让那个效果变成「对方选1张手卡丢弃」。
function c53199020.initial_effect(c)
	-- 这张卡可以把1只「魔轰神」怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53199020,0))  --"把1只名字带有「魔轰神」的怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c53199020.otcon)
	e1:SetOperation(c53199020.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方把通常魔法卡发动的场合，1回合只有1次让那个效果变成「对方选1张手卡丢弃」。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53199020.chcon1)
	e2:SetOperation(c53199020.chop1)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，对方把通常魔法卡发动的场合，1回合只有1次让那个效果变成「对方选1张手卡丢弃」。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c53199020.chcon2)
	e3:SetOperation(c53199020.chop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回名字带有「魔轰神」且处于场上或由玩家控制的怪兽
function c53199020.otfilter(c,tp)
	return c:IsSetCard(0x35) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤条件判断：检查是否满足等级7以上、只需1个祭品、并且能从场上选择符合条件的祭品
function c53199020.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的祭品怪兽组（包括自己场上的和对方场上的）
	local mg=Duel.GetMatchingGroup(c53199020.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回是否满足上级召唤条件：等级≥7，所需祭品数≤1，且能从mg中找到合适的祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤操作函数：选择并解放1只符合条件的祭品怪兽
function c53199020.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足条件的祭品怪兽组（包括自己场上的和对方场上的）
	local mg=Duel.GetMatchingGroup(c53199020.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从mg中选择1个祭品怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品怪兽解放，用于上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 连锁发动时的条件判断：判断是否为对方发动通常魔法卡
function c53199020.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:GetHandler():GetType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 连锁发动时的操作函数：给被发动的魔法卡注册一个标记，表示该效果已被处理过
function c53199020.chop1(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():RegisterFlagEffect(53199020,RESET_CHAIN,0,1)
end
-- 连锁处理开始时的条件判断：判断被发动的魔法卡是否有标记
function c53199020.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():GetFlagEffect(53199020)>0
end
-- 连锁处理开始时的操作函数：将该连锁的目标改为无目标，并替换其处理函数为丢弃手卡的效果
function c53199020.chop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将连锁的目标改为无目标
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁效果的处理函数替换为丢弃手卡的函数
	Duel.ChangeChainOperation(ev,c53199020.rep_op)
end
-- 替代效果处理函数：提示对方丢弃1张手卡
function c53199020.rep_op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方发动了魔轰神狄阿尼拉的效果
	Duel.Hint(HINT_CARD,0,53199020)
	-- 让对方丢弃1张手卡
	Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
end
