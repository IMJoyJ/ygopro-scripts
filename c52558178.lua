--パワーコネクション
local s,id,o=GetID()
-- 初始化卡片效果：注册群体攻击力上升、墓地自身回收效果，并添加发动检测计数器
function s.initial_effect(c)
	-- 记录卡片密码「武装转生」到关联卡片列表
	aux.AddCodeList(c,53770666)
	-- ①：以自己场上最多7只相同种族的表侧表示怪兽为对象才能发动。那些怪兽的攻击力直到回合结束时上升作为对象的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己把「武装转生」发动的回合，把墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器：记录本回合是否发动过「武装转生」
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤计数器统计的行为：发动「武装转生」的魔法·陷阱卡效果
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsCode(53770666) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 过滤自己场上可成为效果对象的表侧表示怪兽
function s.atkfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 检查卡片组中是否存在与自身种族不同的怪兽
function s.cfilter(c,g)
	-- 判定卡片组中的所有怪兽是否与自身种族相同
	return not g:IsExists(aux.NOT(Card.IsRace),1,c,c:GetRace())
end
-- 检查所选怪兽组是否全为相同种族
function s.gcheck(g)
	if g:GetCount()==1 then return true end
	return g:IsExists(s.cfilter,1,nil,g)
end
-- 卡片发动取对象：选择自己场上最多7只相同种族的表侧表示怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有可作为对象的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc,e) end
	-- 检查自己场上是否存在可成为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,7)
	-- 将选中的怪兽组设置为效果对象
	Duel.SetTargetCard(sg)
end
-- 效果处理：对象怪兽的攻击力直到回合结束时上升对象数量×500
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与本次连锁相关且仍在场上表侧表示的对象怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER):Filter(Card.IsFaceup,nil)
	-- 遍历所有有效的对象怪兽
	for tc in aux.Next(g) do
		-- 那些怪兽的攻击力直到回合结束时上升作为对象的怪兽数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(g:GetCount()*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 回收效果的发动条件判定
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否已发动过「武装转生」
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
end
-- 回收效果的目标判定及操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将墓地的自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理：将墓地的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身与连锁有联系且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入持有者手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
