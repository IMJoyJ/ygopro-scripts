--ブンボーグ002
-- 效果：
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「文具电子人」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的机械族怪兽的攻击力·守备力上升500。
function c59368956.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「文具电子人」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59368956,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(c59368956.target)
	e1:SetOperation(c59368956.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的机械族怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c59368956.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「文具电子人」卡片且该卡能加入手牌的条件
function c59368956.filter(c)
	return c:IsSetCard(0xab) and c:IsAbleToHand()
end
-- ①号效果的发动条件检测与操作信息设置
function c59368956.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「文具电子人」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c59368956.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的执行：从卡组选择1张「文具电子人」卡加入手牌并给对方确认
function c59368956.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「文具电子人」卡片
	local g=Duel.SelectMatchingCard(tp,c59368956.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自身以外的自己场上的机械族怪兽作为攻击力/守备力上升效果的对象
function c59368956.atktg(e,c)
	return c:IsRace(RACE_MACHINE) and c~=e:GetHandler()
end
