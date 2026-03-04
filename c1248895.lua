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
-- 过滤函数，用于筛选满足条件的怪兽（表侧表示、攻击力2000以下、可成为效果对象）
function c1248895.filter(c,e)
	return c:IsFaceup() and c:IsAttackBelow(2000) and c:IsCanBeEffectTarget(e)
end
-- 设置连锁破坏效果的目标选择函数
function c1248895.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(c1248895.filter,1,nil,e) end
	if eg:GetCount()==1 then
		-- 当连锁中只有一只符合条件的怪兽时，直接将该怪兽设为效果对象
		Duel.SetTargetCard(eg)
	else
		-- 向玩家提示选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=eg:FilterSelect(tp,c1248895.filter,1,1,nil,e)
		-- 从符合条件的怪兽中选择一只作为效果对象
		Duel.SetTargetCard(g)
	end
end
-- 设置连锁破坏效果的发动处理函数
function c1248895.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local tpe=tc:GetType()
	if bit.band(tpe,TYPE_TOKEN)~=0 then return end
	-- 检索对象怪兽控制者的手卡和卡组中所有同名卡
	local dg=Duel.GetMatchingGroup(Card.IsCode,tc:GetControler(),LOCATION_DECK+LOCATION_HAND,0,nil,tc:GetCode())
	-- 将检索到的同名卡全部破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
