--BF－暁のシロッコ
-- 效果：
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作通常召唤。
-- ②：1回合1次，自己主要阶段1以自己场上1只「黑羽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那只怪兽以外的场上的「黑羽」怪兽的攻击力的合计数值。这个效果发动的回合，不用作为对象的怪兽不能攻击。
function c75498415.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75498415,0))  --"不用祭品召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c75498415.ntcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段1以自己场上1只「黑羽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那只怪兽以外的场上的「黑羽」怪兽的攻击力的合计数值。这个效果发动的回合，不用作为对象的怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75498415,1))  --"攻击上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c75498415.condition)
	e3:SetTarget(c75498415.target)
	e3:SetOperation(c75498415.operation)
	c:RegisterEffect(e3)
end
-- 判定是否满足不用解放作通常召唤的条件
function c75498415.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定是不需要解放的通常召唤、怪兽等级在5星以上且自己场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定自己场上没有怪兽存在
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判定对方场上有怪兽存在
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
end
-- 判定是否在主要阶段1发动
function c75498415.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤场上表侧表示的「黑羽」怪兽
function c75498415.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 效果②的靶向处理，选择自己场上1只表侧表示的「黑羽」怪兽作为对象，并注册“不用作为对象的怪兽不能攻击”的限制
function c75498415.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c75498415.filter(chkc) end
	-- 判定自己场上是否存在可以作为对象的表侧表示「黑羽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c75498415.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「黑羽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75498415.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 那只怪兽的攻击力直到回合结束时上升那只怪兽以外的场上的「黑羽」怪兽的攻击力的合计数值。这个效果发动的回合，不用作为对象的怪兽不能攻击。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c75498415.ftarget)
	e2:SetLabel(g:GetFirst():GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册“不用作为对象的怪兽不能攻击”的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果②的执行处理，计算场上其他「黑羽」怪兽的攻击力合计，并使作为对象的怪兽攻击力上升该数值
function c75498415.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=0
		-- 获取场上除作为对象的怪兽以外的所有表侧表示的「黑羽」怪兽
		local g=Duel.GetMatchingGroup(c75498415.filter,tp,LOCATION_MZONE,LOCATION_MZONE,tc)
		local bc=g:GetFirst()
		while bc do
			atk=atk+bc:GetAttack()
			bc=g:GetNext()
		end
		-- 那只怪兽的攻击力直到回合结束时上升那只怪兽以外的场上的「黑羽」怪兽的攻击力的合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
-- 过滤不能攻击的怪兽，即卡片ID不等于作为效果对象的怪兽
function c75498415.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
