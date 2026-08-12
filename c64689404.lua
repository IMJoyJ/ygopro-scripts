--ソードブレイカー
-- 效果：
-- 6星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，宣言1个种族才能发动。这张卡和宣言的种族的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c64689404.initial_effect(c)
	-- 添加XYZ召唤手续，需要2只6星怪兽
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，宣言1个种族才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64689404,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c64689404.raccost)
	e1:SetTarget(c64689404.ractg)
	e1:SetOperation(c64689404.racop)
	c:RegisterEffect(e1)
	-- 这张卡和宣言的种族的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64689404,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c64689404.descon)
	e2:SetTarget(c64689404.destg)
	e2:SetOperation(c64689404.desop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 起动效果的Cost：检查并取除这张卡的1个超量素材
function c64689404.raccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 起动效果的Target：检查是否已宣言所有种族，注册重置标记，并让玩家宣言一个未宣言过的种族
function c64689404.ractg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetLabel()~=RACE_ALL end
	if e:GetHandler():GetFlagEffect(64689404)==0 then
		e:GetHandler():RegisterFlagEffect(64689404,RESET_EVENT+RESETS_STANDARD,0,0)
		e:GetLabelObject():SetLabel(0)
	end
	local prc=e:GetLabelObject():GetLabel()
	-- 向玩家发送提示信息，提示选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从尚未宣言过的种族中宣言1个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL-prc)
	e:SetLabel(rc)
end
-- 起动效果的Operation：将新宣言的种族与之前宣言的种族合并，保存到诱发效果的Label中，并在卡片上显示宣言的种族
function c64689404.racop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() then
		local prc=e:GetLabelObject():GetLabel()
		local rc=bit.bor(e:GetLabel(),prc)
		e:GetLabelObject():SetLabel(rc)
		e:GetHandler():SetHint(CHINT_RACE,rc)
	end
end
-- 诱发效果的Condition：这张卡有发动过宣言效果的标记，且战斗对象是表侧表示的、属于宣言种族的怪兽
function c64689404.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:GetFlagEffect(64689404)~=0 and bc and bc:IsFaceup() and bc:IsRace(e:GetLabel())
end
-- 诱发效果的Target：设置破坏战斗对象的操作信息
function c64689404.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，确定要破坏1只进行战斗的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 诱发效果的Operation：如果战斗对象仍在战斗中，则将其破坏
function c64689404.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 因效果破坏该战斗对象怪兽
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
