--幻蝶の刺客モルフォ
-- 效果：
-- 对方场上的怪兽的表示形式变更时，选择那1只怪兽才能发动。选择的怪兽的攻击力·守备力下降1000。这个效果1回合只能使用1次。
function c43573231.initial_effect(c)
	-- 对方场上的怪兽的表示形式变更时，选择那1只怪兽才能发动。选择的怪兽的攻击力·守备力下降1000。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43573231,0))  --"攻守下降"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c43573231.adtg)
	e1:SetOperation(c43573231.adop)
	c:RegisterEffect(e1)
end
-- 筛选条件：对象必须是对方场上的怪兽，且其表示形式发生了从表侧攻击表示变为表侧守备表示、从表侧守备表示变为表侧攻击表示、或从里侧守备表示变为表侧攻击表示的变更，并且该怪兽能够成为当前效果的对象。
function c43573231.cfilter(c,e,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsControler(tp) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1) or (pp==0x8 and np==0x1)) and c:IsCanBeEffectTarget(e)
end
-- 效果发动的合法性判定与取对象处理：若连锁处理中指定对象，则确认对象在诱发组中且满足筛选条件；若在发动时点判断，则要求诱发组中存在至少1只符合条件的对方怪兽；随后提示玩家从符合条件的怪兽中选择1只，并将其设置为效果对象。
function c43573231.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c43573231.cfilter(chkc,e,1-tp) end
	if chk==0 then return eg:IsExists(c43573231.cfilter,1,nil,e,1-tp) end
	-- 给发动玩家显示选择对象的提示消息，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c43573231.cfilter,1,1,nil,e,1-tp)
	-- 将玩家选择的那只怪兽登记为当前连锁的效果对象，使后续处理以它为对象。
	Duel.SetTargetCard(g)
end
-- 效果处理时，取得对象怪兽；若该怪兽仍表侧表示且与效果仍有联系（未离场且对象关系有效），则对其注册攻击力下降1000的持续效果，再克隆出守备力下降1000的效果，使对象怪兽攻击力·守备力各下降1000。
function c43573231.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的效果对象（即发动时选择的1只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
