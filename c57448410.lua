--プリマ・マテリアクトル
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己场上的超量怪兽的攻击力上升场上的超量素材数量×100。
-- ②：以自己场上1只「原质炉」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。那之后，自己抽1张。
-- 【怪兽描述】
-- 从遥远彼端的天上界突然飞来的外来生命体。虽有众多研究者力图查明真身，但其发放的光辉和弥漫的瘴气导致长久以来其存在被谜团所笼罩，想要一睹全貌极为困难。然而，近年来，经过新进研究者的一番努力发现了许多新种。揭开其全貌的日子想必也已临近。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆属性启用、①的攻击力上升效果和②的叠放抽卡效果
function s.initial_effect(c)
	-- 启用灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的超量怪兽的攻击力上升场上的超量素材数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为超量怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「原质炉」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"作为超量素材"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升值的辅助函数
function s.val(e,c)
	-- 获取双方场上所有超量素材的数量并乘以100作为攻击力上升值
	return Duel.GetOverlayCount(e:GetHandlerPlayer(),1,1)*100
end
-- 过滤自己场上表侧表示的「原质炉」超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x160) and c:IsType(TYPE_XYZ)
end
-- ②的效果发动时的目标选择与合法性检测函数
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的「原质炉」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1)
		and e:GetHandler():IsCanOverlay() end
	-- 向玩家发送选择效果对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「原质炉」超量怪兽作为效果对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②的效果处理函数，将自身作为超量素材并抽卡
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
		-- 将这张卡作为目标怪兽的超量素材叠放
		Duel.Overlay(tc,Group.FromCards(c))
		-- 中断效果处理，使后续的抽卡处理不与叠放素材视为同时进行
		Duel.BreakEffect()
		-- 让玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
