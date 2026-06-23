--守護神エクゾディア
-- 效果：
-- 这张卡不能特殊召唤。这张卡的①的方法召唤的这张卡战斗破坏原本持有者是对方的恶魔族·暗属性怪兽时，自己决斗胜利。
-- ①：这张卡也能把5只怪兽解放作召唤。
-- ②：这张卡的攻击力·守备力变成因为这张卡召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
function c5008836.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- ①：这张卡也能把5只怪兽解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5008836,0))  --"解放5只怪兽作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c5008836.ttcon)
	e1:SetOperation(c5008836.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力变成因为这张卡召唤而解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c5008836.valcheck)
	c:RegisterEffect(e2)
	-- 这张卡的①的方法召唤的这张卡战斗破坏原本持有者是对方的恶魔族·暗属性怪兽时，自己决斗胜利。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetOperation(c5008836.facechk)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 判断是否满足解放5只怪兽进行召唤的条件
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5008836,1))
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(c5008836.wincon)
	e4:SetOperation(c5008836.winop)
	c:RegisterEffect(e4)
end
-- 当召唤所需祭品数量不超过5且场上存在足够祭品时返回true
function c5008836.ttcon(e,c,minc)
	if c==nil then return true end
	-- 选择并解放5只怪兽作为召唤的祭品
	return minc<=5 and Duel.CheckTribute(c,5)
end
-- 向玩家提示选择要解放的卡
function c5008836.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从场上选择5只怪兽作为召唤的祭品
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 将选中的祭品解放
	local g=Duel.SelectTribute(tp,c,5,5)
	c:SetMaterial(g)
	-- 计算并设置攻击力和守备力
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 设置自身攻击力为解放怪兽攻击力总和
function c5008836.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	local def=0
	while tc do
		atk=atk+math.max(tc:GetTextAttack(),0)
		def=def+math.max(tc:GetTextDefense(),0)
		tc=g:GetNext()
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 设置自身守备力为解放怪兽守备力总和
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
-- 标记材料检查已执行
function c5008836.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
-- 判断战斗破坏的怪兽是否为对方的恶魔族·暗属性怪兽
function c5008836.winfilter(e,c)
	return c:GetOwner()==1-e:GetHandlerPlayer()
		and c:GetPreviousRaceOnField()&RACE_FIEND~=0 and c:GetPreviousAttributeOnField()&ATTRIBUTE_DARK~=0
end
-- 判断是否满足胜利条件：召唤方式为①方法且战斗破坏的是对方恶魔族·暗属性怪兽
function c5008836.wincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗攻击的卡
	local tc=Duel.GetAttacker()
	-- 若自身为攻击方，则获取攻击目标
	if c==tc then tc=Duel.GetAttackTarget() end
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return c:GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF and c5008836.winfilter(e,tc)
end
-- 令玩家以守护神艾克佐迪亚胜利
function c5008836.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_GUARDIAN_GOD_EXODIA=0x1f
	-- 执行决斗胜利判定
	Duel.Win(tp,WIN_REASON_GUARDIAN_GOD_EXODIA)
end
