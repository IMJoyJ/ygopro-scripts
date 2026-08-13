--ガーゴイルの道化師
-- 效果：
-- 这张卡片召唤·反转召唤·特殊召唤时可以使对方1只表侧表示的怪兽的表示形式改变。
function c42647539.initial_effect(c)
	-- 这张卡片召唤·反转召唤·特殊召唤时可以使对方1只表侧表示的怪兽的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42647539,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c42647539.postg)
	e1:SetOperation(c42647539.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数：选择场上表侧表示且可以被效果改变表示形式的怪兽。
function c42647539.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果发动时的目标处理：从对方场上选择1只表侧表示且可改变表示形式的怪兽作为对象；没有满足条件的卡时不能发动。
function c42647539.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c42647539.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家tp显示选择提示“请选择表侧表示的卡”，用于选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方怪兽区域选择1只满足过滤条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c42647539.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设定当前连锁的操作信息：将进行表示形式变更，对象为g中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时：取得对象，若对象仍与效果相关且表侧表示，则将其表示形式改变为相反的形式（攻击表示变守备，守备表示变攻击）。
function c42647539.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 改变目标怪兽的表示形式：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
