--カラクリ忍者 七七四九
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变更。这张卡召唤成功时，可以从自己卡组抽出自己场上表侧守备表示存在的名字带有「机巧」的怪兽数量的卡。
function c50615578.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50615578,0))  --"表示形式变更"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetOperation(c50615578.posop)
	c:RegisterEffect(e3)
	-- 这张卡召唤成功时，可以从自己卡组抽出自己场上表侧守备表示存在的名字带有「机巧」的怪兽数量的卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50615578,1))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c50615578.drtg)
	e4:SetOperation(c50615578.drop)
	c:RegisterEffect(e4)
end
-- 处理「表示形式变更」效果：若这张卡仍表侧表示且与效果关联，则将其表侧攻击表示与表侧守备表示互换。
function c50615578.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 变更这张卡的表示形式：表侧攻击表示改为表侧守备表示，表侧守备表示改为表侧攻击表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 过滤条件：表侧守备表示且名字带有「机巧」的怪兽。
function c50615578.drfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x11)
end
-- 抽卡效果的发动条件与对象设定：计算自己场上符合条件（表侧守备表示且名字带有「机巧」）的怪兽数量ct；ct大于0且自己可以抽ct张卡时允许发动；将发动玩家和抽卡数量记录为效果处理时使用的信息。
function c50615578.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上表侧守备表示且名字带有「机巧」的怪兽数量，作为抽卡张数。
	local ct=Duel.GetMatchingGroupCount(c50615578.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动条件判定：存在符合条件（表侧守备表示且名字带有「机巧」）的怪兽（ct>0），且自己可以抽ct张卡。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 将当前连锁的对象玩家设为自己（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为抽卡数量ct，供处理阶段获取。
	Duel.SetTargetParam(ct)
	-- 设置操作信息：此次效果为抽卡效果，目标玩家为tp，预计抽卡张数为ct。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 抽卡效果处理：重新计算自己场上符合条件的「机巧」怪兽数量，获取发动时记录的目标玩家，令其抽相应数量的卡。
function c50615578.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算自己场上表侧守备表示且名字带有「机巧」的怪兽数量，作为实际抽卡张数。
	local ct=Duel.GetMatchingGroupCount(c50615578.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取当前连锁处理中记录的目标玩家（发动时通过SetTargetPlayer设置的对象玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让目标玩家以效果原因抽取ct张卡。
	Duel.Draw(p,ct,REASON_EFFECT)
end
