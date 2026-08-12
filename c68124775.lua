--オリエント・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，选择对方场上1只同调怪兽从游戏中除外。
function c68124775.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，选择对方场上1只同调怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68124775,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c68124775.condition)
	e1:SetTarget(c68124775.target)
	e1:SetOperation(c68124775.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否是通过同调召唤成功特殊召唤
function c68124775.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤场上表侧表示、属于同调怪兽且可以被除外的卡片
function c68124775.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
-- 效果发动的目标选择阶段，确认是否存在合法的除外对象，并选择对方场上1只表侧表示的同调怪兽作为效果对象
function c68124775.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c68124775.filter(chkc) end
	if chk==0 then return true end
	-- 给发动效果的玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只满足过滤条件的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68124775.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息，表示该连锁的处理包含将选中的卡片除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理阶段，获取选中的对象，若其仍在场上表侧表示且仍为该效果的对象，则将其除外
function c68124775.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将选中的对象怪兽以效果表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
