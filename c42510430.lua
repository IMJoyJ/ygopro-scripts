--サンセット・ビート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧守备表示的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己场上的反转怪兽反转的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。给与对方那只怪兽的等级×200伤害。
local s,id,o=GetID()
-- 定义并注册该卡的效果：e1为魔陷发动用空效果；e2为①效果（表侧怪兽变里侧时以场上1张卡为对象破坏）；e3为②效果（反转怪兽反转时给予对方等级×200伤害）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧守备表示的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：自己场上的反转怪兽反转的场合，以那之内的1只为对象才能发动（伤害步骤也能发动）。给与对方那只怪兽的等级×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- ①效果的条件筛选：判断怪兽是否满足“之前表侧表示→现在里侧表示”且控制者为触发玩家。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- ①效果的发动条件：本次表示形式变更的怪兽中存在控制者为自己的、从表侧变为里侧表示的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的发动时处理：选择场上1张卡作为对象，并设置要破坏该卡的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性检查：场上是否存在至少1张可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家选择场上1张卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：将破坏对象卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的解决处理：取得对象卡，若其仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的条件筛选：判断怪兽是否满足“之前里侧表示→现在表侧表示”且为控制者自己的反转怪兽，并能成为效果对象。
function s.cfilter2(c,tp,e)
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_FLIP) and c:IsCanBeEffectTarget(e)
end
-- ②效果的发动条件：本次表示形式变更的怪兽中存在控制者自己的反转怪兽变为表侧表示的卡。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp,e)
end
-- 对象合法性检查：确认候选卡属于本次反转的怪兽、原控制者为触发玩家、之前位于主要怪兽区且满足②的筛选条件。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsPreviousControler(tp)
		and chkc:IsPreviousLocation(LOCATION_MZONE) and s.cfilter2(chkc,tp,e) end
	local g=eg:Filter(s.cfilter2,nil,tp,e)
	-- 效果发动合法性检查：确认存在可作为对象的反转怪兽（#g>0），并调用Duel.GetLocationCount获取主要怪兽区空格数（此处未显式判断其值）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE) and #g>0 end
	-- 显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	-- 将选择的反转怪兽登记为当前连锁的对象，并在效果上保存该卡。
	Duel.SetTargetCard(tc)
	e:SetLabelObject(tc)
	-- 设置当前连锁的操作信息：对对方造成该怪兽等级×200的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetLevel()*200)
end
-- ②效果的解决处理：取得保存的对象怪兽，若其仍与效果关联且为表侧表示的怪兽，则给予对方伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToEffect(e) or not tc:IsPosition(POS_FACEUP) or not tc:IsType(TYPE_MONSTER) then return end
	-- 以效果原因向对方玩家造成该怪兽等级×200的伤害。
	Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
end
