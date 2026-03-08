--熒焅聖 アレクゥス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。那之后，自己抽1张。
-- ③：这张卡被破坏的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 注册三个效果：①特殊召唤效果、②破坏并抽卡效果、③被破坏时作为超量素材效果
function s.initial_effect(c)
	-- ①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，以自己场上1只超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"作为超量素材"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否有表侧表示的魔法或陷阱卡
function s.spcfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 特殊召唤条件函数：判断是否满足特殊召唤条件（有空场和魔法陷阱卡）
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家场上是否存在满足条件的魔法或陷阱卡
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 过滤函数：检查是否为表侧表示的魔法或陷阱卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动条件判断函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and s.desfilter(chkc) end
	if chk==0 then return c:IsDestructable()
		-- 判断是否场上存在满足条件的魔法或陷阱卡作为对象
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,c)
		-- 判断玩家是否可以抽一张卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择破坏对象卡
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(c)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 破坏效果的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() then
		local g=Group.FromCards(c,tc)
		-- 执行破坏操作并判断是否成功破坏两张卡
		if Duel.Destroy(g,REASON_EFFECT)==2 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 执行抽卡效果
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 过滤函数：检查是否为表侧表示的超量怪兽
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 超量素材效果的发动条件判断函数
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc) end
	-- 判断是否场上存在满足条件的超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择超量素材对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择超量素材对象卡
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置离开墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 超量素材效果的处理函数
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e)
		-- 判断对象怪兽和自身是否满足叠放条件
		and c:IsRelateToChain() and c:IsCanOverlay() and aux.NecroValleyFilter()(c) then
		-- 执行叠放操作
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
