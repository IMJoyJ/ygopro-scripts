--ゴヨウ・キング
-- 效果：
-- 调整＋调整以外的同调怪兽1只以上
-- ①：这张卡向对方怪兽攻击的攻击宣言时发动。这张卡的攻击力直到伤害步骤结束时上升自己场上的战士族·地属性的同调怪兽数量×400。
-- ②：这张卡战斗破坏对方怪兽送去墓地时，可以从以下效果选择1个发动。
-- ●破坏的那只怪兽在自己场上特殊召唤。
-- ●选对方场上1只表侧表示怪兽得到控制权。
function c84305651.initial_effect(c)
	-- 设置同调召唤手续：需要1只调整和1只以上调整以外的同调怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：这张卡向对方怪兽攻击的攻击宣言时发动。这张卡的攻击力直到伤害步骤结束时上升自己场上的战士族·地属性的同调怪兽数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84305651,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c84305651.atkcon)
	e1:SetOperation(c84305651.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽送去墓地时，可以从以下效果选择1个发动。●破坏的那只怪兽在自己场上特殊召唤。●选对方场上1只表侧表示怪兽得到控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 设置发动条件为：自身战斗破坏对方怪兽并送去墓地
	e2:SetCondition(aux.bdogcon)
	e2:SetTarget(c84305651.sptg)
	e2:SetOperation(c84305651.spop)
	c:RegisterEffect(e2)
end
c84305651.material_type=TYPE_SYNCHRO
-- 攻击力上升效果的发动条件判定函数
function c84305651.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在攻击对象（即是否向对方怪兽进行攻击）
	return Duel.GetAttackTarget()~=nil
end
-- 攻击力上升效果的执行函数
function c84305651.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取自己场上表侧表示的战士族·地属性同调怪兽的数量
		local ct=Duel.GetMatchingGroupCount(c84305651.filter,tp,LOCATION_MZONE,0,nil)
		-- 这张卡的攻击力直到伤害步骤结束时上升自己场上的战士族·地属性的同调怪兽数量×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己场上表侧表示的战士族·地属性同调怪兽
function c84305651.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 过滤对方场上表侧表示且可以转移控制权的怪兽
function c84305651.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 战斗破坏怪兽时效果的发动准备与分支选择函数
function c84305651.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查自己场上是否有空位，且被破坏的怪兽是否可以特殊召唤
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 检查对方场上是否存在可以转移控制权的表侧表示怪兽
	local b2=Duel.IsExistingMatchingCard(c84305651.ctfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个效果都满足时，让玩家选择“特殊召唤”或“得到控制权”
		op=Duel.SelectOption(tp,aux.Stringid(84305651,1),aux.Stringid(84305651,2))  --"特殊召唤/得到控制权"
	elseif b1 then
		-- 当仅满足特殊召唤条件时，让玩家确认选择“特殊召唤”
		op=Duel.SelectOption(tp,aux.Stringid(84305651,1))  --"特殊召唤"
	else
		-- 当仅满足控制权转移条件时，让玩家确认选择“得到控制权”并调整选项索引
		op=Duel.SelectOption(tp,aux.Stringid(84305651,2))+1  --"得到控制权"
	end
	if op==0 then
		-- 将战斗破坏的怪兽设为效果处理的对象
		Duel.SetTargetCard(bc)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤的操作信息，包含目标怪兽和数量
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
	else
		e:SetCategory(CATEGORY_CONTROL)
	end
	e:SetLabel(op)
end
-- 战斗破坏怪兽时效果的执行函数
function c84305651.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取之前设为效果对象的战斗破坏怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要转移控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家选择对方场上1只满足条件的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,c84305651.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 获得所选怪兽的控制权
			Duel.GetControl(tc,tp)
		end
	end
end
