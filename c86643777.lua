--光虫基盤
-- 效果：
-- 「光虫基盘」的②的效果1回合只能使用1次。
-- ①：自己场上的昆虫族怪兽的攻击力·守备力上升300。
-- ②：以自己场上1只昆虫族超量怪兽为对象才能发动。把手卡1只昆虫族怪兽在那只怪兽下面重叠作为超量素材。
function c86643777.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的昆虫族怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为昆虫族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：以自己场上1只昆虫族超量怪兽为对象才能发动。把手卡1只昆虫族怪兽在那只怪兽下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(86643777,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,86643777)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c86643777.target)
	e4:SetOperation(c86643777.operation)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的昆虫族超量怪兽
function c86643777.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_INSECT)
end
-- 过滤条件：手卡中可以作为超量素材的昆虫族怪兽
function c86643777.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsCanOverlay()
end
-- 效果②的发动准备与合法性检测
function c86643777.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86643777.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的昆虫族超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c86643777.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己手卡中是否存在至少1只可以作为超量素材的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c86643777.matfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的昆虫族超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c86643777.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理：将手卡中的昆虫族怪兽重叠为作为对象的超量怪兽的超量素材
function c86643777.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从手卡选择1只满足条件的昆虫族怪兽
		local g=Duel.SelectMatchingCard(tp,c86643777.matfilter,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的手卡怪兽重叠在作为对象的超量怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
