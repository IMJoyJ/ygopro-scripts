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
	-- 这张卡的①的方法召唤的这张卡
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetOperation(c5008836.facechk)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 这张卡的①的方法召唤的这张卡战斗破坏原本持有者是对方的恶魔族·暗属性怪兽时，自己决斗胜利。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5008836,1))
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(c5008836.wincon)
	e4:SetOperation(c5008836.winop)
	c:RegisterEffect(e4)
end
-- 召唤规则效果的发动条件：检查是否存在足够祭品；c为空时为了规则显示而返回true，通常要求解放数不超过5且Duel.CheckTribute确认有5只可供解放的怪兽。
function c5008836.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判定所需解放数不大于5，且场上确实有5只可供解放的怪兽；满足条件才允许通过①的规则进行召唤。
	return minc<=5 and Duel.CheckTribute(c,5)
end
-- 执行①的召唤手续：提示玩家选择解放怪兽，选择5只祭品，将它们设为这张卡的召唤素材并解放，从而完成以5只怪兽解放作召唤。
function c5008836.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 向当前玩家显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让当前玩家从场上选择5只怪兽作为这张卡召唤用的祭品。
	local g=Duel.SelectTribute(tp,c,5,5)
	c:SetMaterial(g)
	-- 将所选5只祭品怪兽以召唤素材的方式解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 素材检查操作：累计这张卡召唤时解放的怪兽的原本攻击力和守备力；若已通过①的方法召唤（label为1），则生成并注册将其攻击力、守备力分别变成该合计数值的效果。
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
		-- ②：这张卡的攻击力变成因为这张卡召唤而解放的怪兽的原本的攻击力合计数值。
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
-- 为素材检查效果打上标记，表示这张卡是通过①的方法解放5只怪兽进行的召唤。
function c5008836.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
-- 判断战斗破坏的怪兽是否原本持有者为对方，并且其在场上时的种族为恶魔族、属性为暗属性。
function c5008836.winfilter(e,c)
	return c:GetOwner()==1-e:GetHandlerPlayer()
		and c:GetPreviousRaceOnField()&RACE_FIEND~=0 and c:GetPreviousAttributeOnField()&ATTRIBUTE_DARK~=0
end
-- 胜利触发条件：这张卡是用①的方法召唤的，且在这次战斗中用这张卡破坏了满足对方恶魔族·暗属性条件的怪兽；同时这张卡仍与战斗相关且为表侧表示。
function c5008836.wincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这次战斗中的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 若这张卡是攻击方，则被判定战斗破坏的怪兽应取攻击目标。
	if c==tc then tc=Duel.GetAttackTarget() end
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return c:GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF and c5008836.winfilter(e,tc)
end
-- 执行胜利处理：以“守护神 艾克佐迪亚”的专用胜利原因让当前玩家获得决斗胜利。
function c5008836.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_GUARDIAN_GOD_EXODIA=0x1f
	-- 宣告当前玩家获得决斗胜利。
	Duel.Win(tp,WIN_REASON_GUARDIAN_GOD_EXODIA)
end
