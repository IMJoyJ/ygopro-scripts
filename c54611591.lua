--イタズラの大精霊ハロ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。这张卡在自己场上表侧表示存在的场合，对方从以下效果选1个，自己让那个效果适用。
-- ●这张卡的攻击力上升自己墓地的恶魔族怪兽数量×800。
-- ●给与对方为自己墓地的恶魔族怪兽数量×500伤害。
-- ②：这张卡被战斗·效果破坏的场合才能发动。对方场上1只怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡片效果：①效果（召唤·特殊召唤时发动，对方选择适用效果）与②效果（被破坏时发动，对方场上怪兽送墓）
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。这张卡在自己场上表侧表示存在的场合，对方从以下效果选1个，自己让那个效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升或者给予伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。对方场上1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"对手怪兽送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- ①效果的发动准备与可行性检查函数
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_FIEND) end
end
-- ①效果的处理函数：若此卡在场上表侧表示存在，则由对方选择一项效果适用
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	-- 获取自己墓地的恶魔族怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_FIEND)
	if ct==0 then return end
	-- 让对方玩家从“攻击力上升”和“给予伤害”中选择一个效果适用
	local res=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"攻击力上升/伤害给与"
	if res==0 then
		-- ●这张卡的攻击力上升自己墓地的恶魔族怪兽数量×800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*800)
		c:RegisterEffect(e1)
	elseif res==1 then
		-- 给予对方自己墓地恶魔族怪兽数量×500的伤害
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
-- ②效果的发动条件：此卡被战斗或效果破坏
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT+REASON_BATTLE)~=0
end
-- ②效果的发动准备与可行性检查函数，设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置连锁中的操作信息为将对方场上的1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果的处理函数：选择对方场上1只怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上怪兽区的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 在场上显式示出被选择的卡片
	Duel.HintSelection(sg)
	-- 将选中的卡片因效果送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
