--LL－バード・サンクチュアリ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上2只鸟兽族超量怪兽为对象才能发动。作为对象的怪兽之内1只在另1只怪兽下面重叠作为超量素材（把持有超量素材的怪兽重叠的场合那些超量素材也全部重叠）。
-- ②：持有超量素材3个以上的超量怪兽在自己场上存在的场合才能发动。自己从卡组抽1张。
function c72859417.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：以自己场上2只鸟兽族超量怪兽为对象才能发动。作为对象的怪兽之内1只在另1只怪兽下面重叠作为超量素材（把持有超量素材的怪兽重叠的场合那些超量素材也全部重叠）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72859417,0))  --"叠放"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,72859417)
	e1:SetTarget(c72859417.target)
	e1:SetOperation(c72859417.activate)
	c:RegisterEffect(e1)
	-- ②：持有超量素材3个以上的超量怪兽在自己场上存在的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72859417,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,72859418)
	e2:SetCondition(c72859417.drcon)
	e2:SetTarget(c72859417.drtg)
	e2:SetOperation(c72859417.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、可以成为效果对象的鸟兽族超量怪兽
function c72859417.ovfilter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
-- 检查卡片组中是否至少有1张卡可以作为超量素材叠放
function c72859417.gcheck(g)
	return g:IsExists(Card.IsCanOverlay,1,nil)
end
-- 效果①的发动准备：选择自己场上2只满足条件的鸟兽族超量怪兽作为对象
function c72859417.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有满足条件的鸟兽族超量怪兽
	local g=Duel.GetMatchingGroup(c72859417.ovfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c72859417.gcheck,2,2) end
	-- 提示玩家选择作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c72859417.gcheck,false,2,2)
	-- 将选中的2只怪兽注册为当前连锁的效果对象
	Duel.SetTargetCard(sg)
end
-- 效果①的处理：将其中1只怪兽及其超量素材全部重叠到另1只怪兽下面作为超量素材
function c72859417.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍存在于场上的效果对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if #g<2 then return end
	if g:IsExists(Card.IsImmuneToEffect,1,nil,e) then return end
	-- 提示玩家选择要作为超量素材叠放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local c1=g:FilterSelect(tp,Card.IsCanOverlay,1,1,nil):GetFirst()
	if not c1 then return end
	local c2=(g-c1):GetFirst()
	local mg=c1:GetOverlayGroup()
	-- 如果被叠放的怪兽持有超量素材，则将那些超量素材也全部重叠到另一只怪兽下面
	if mg:GetCount()>0 then Duel.Overlay(c2,mg,false) end
	-- 将选中的怪兽重叠到另一只怪兽下面作为超量素材
	Duel.Overlay(c2,c1)
end
-- 过滤条件：自己场上表侧表示且持有3个以上超量素材的超量怪兽
function c72859417.drfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=3
end
-- 效果②的发动条件：自己场上存在持有3个以上超量素材的超量怪兽
function c72859417.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只持有3个以上超量素材的超量怪兽
	return Duel.IsExistingMatchingCard(c72859417.drfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动准备：确认玩家是否可以抽卡并设置抽卡操作信息
function c72859417.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的处理：自己从卡组抽1张卡
function c72859417.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
