--連鎖破壊
-- 效果：
-- ①：攻击力2000以下的怪兽召唤·反转召唤·特殊召唤时，以那1只表侧表示怪兽为对象才能发动。从那只表侧表示怪兽的控制者的手卡·卡组把作为对象的怪兽的同名卡全部破坏。
function c1248895.initial_effect(c)
	-- ①：攻击力2000以下的怪兽召唤·反转召唤·特殊召唤时，以那1只表侧表示怪兽为对象才能发动。从那只表侧表示怪兽的控制者的手卡·卡组把作为对象的怪兽的同名卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1248895.target)
	e1:SetOperation(c1248895.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 筛选函数：判断怪兽是否表侧表示、攻击力2000以下且能成为效果对象，用于选出可被本效果选择的召唤成功怪兽。
function c1248895.filter(c,e)
	return c:IsFaceup() and c:IsAttackBelow(2000) and c:IsCanBeEffectTarget(e)
end
-- 发动时选择对象的处理：在连锁确认时校验已选对象是否在召唤成功的那组怪兽中；发动前检查是否存在满足条件的怪兽；若召唤成功的怪兽只有1只则自动设为对象，否则让玩家从其中选择1只并设为对象。
function c1248895.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(c1248895.filter,1,nil,e) end
	if eg:GetCount()==1 then
		-- 当时点只有1只满足条件的怪兽时，直接将该怪兽设置为效果对象。
		Duel.SetTargetCard(eg)
	else
		-- 向当前玩家显示“请选择效果的对象”的选择提示，等待玩家选择对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		local g=eg:FilterSelect(tp,c1248895.filter,1,1,nil,e)
		-- 将玩家选择的那只怪兽设置为效果对象。
		Duel.SetTargetCard(g)
	end
end
-- 效果处理：取得对象怪兽；若对象是衍生物则直接终止；否则找出该对象控制者手卡和卡组中所有与对象同名卡并全部破坏。
function c1248895.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local tpe=tc:GetType()
	if bit.band(tpe,TYPE_TOKEN)~=0 then return end
	-- 获取对象怪兽控制者手卡与卡组中所有与对象怪兽卡号相同的卡片，构成待破坏的卡片组。
	local dg=Duel.GetMatchingGroup(Card.IsCode,tc:GetControler(),LOCATION_DECK+LOCATION_HAND,0,nil,tc:GetCode())
	-- 以效果原因将上述同名卡全部破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
