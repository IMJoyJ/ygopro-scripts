--D－フォース
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把1只「命运英雄 血魔-D」加入手卡。
-- ②：只要自己场上有「命运英雄 血魔-D」存在，以下效果适用。
-- ●自己在抽卡阶段不能抽卡。
-- ●对方不能把自己场上的卡作为效果的对象。
-- ●自己的怪兽区域的「命运英雄 血魔-D」攻击力上升双方墓地的怪兽数量×100，不会被对方的效果破坏，同1次的战斗阶段中可以作2次攻击。
function c6186304.initial_effect(c)
	-- 为卡片添加「命运英雄」系列怪兽列表
	aux.AddSetNameMonsterList(c,0xc008)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把1只「命运英雄 血魔-D」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c6186304.activate)
	c:RegisterEffect(e1)
	-- ●自己在抽卡阶段不能抽卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c6186304.skipcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetValue(0)
	c:RegisterEffect(e3)
	-- ●对方不能把自己场上的卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetCondition(c6186304.condition)
	-- 设置不能成为对方卡的效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ●自己的怪兽区域的「命运英雄 血魔-D」攻击力上升双方墓地的怪兽数量×100
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为卡名是「命运英雄 血魔-D」的怪兽
	e5:SetTarget(aux.TargetBoolFunction(Card.IsCode,83965310))
	e5:SetValue(c6186304.atkval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方的效果破坏
	e6:SetValue(aux.indoval)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_EXTRA_ATTACK)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end
-- 过滤函数：卡名是「命运英雄 血魔-D」且能加入手卡的卡
function c6186304.thfilter(c)
	return c:IsCode(83965310) and c:IsAbleToHand()
end
-- 发动时的效果处理：可以从卡组·墓地把1只「命运英雄 血魔-D」加入手卡
function c6186304.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组·墓地中不受王家之谷影响的「命运英雄 血魔-D」的卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c6186304.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,nil)
	-- 如果存在满足条件的卡，则询问玩家是否发动该效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(6186304,0)) then  --"是否从卡组·墓地选1只「命运英雄 血魔-D」加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤函数：场上表侧表示的「命运英雄 血魔-D」
function c6186304.cfilter(c)
	return c:IsFaceup() and c:IsCode(83965310)
end
-- 效果适用条件：自己场上存在「命运英雄 血魔-D」
function c6186304.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1张表侧表示的「命运英雄 血魔-D」
	return Duel.IsExistingMatchingCard(c6186304.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 抽卡阶段不抽卡效果的适用条件
function c6186304.skipcon(e)
	-- 满足基本条件且当前处于抽卡阶段
	return c6186304.condition(e) and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 计算攻击力上升值的函数
function c6186304.atkval(e,c)
	-- 返回双方墓地的怪兽数量×100的数值
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)*100
end
