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
-- 将目标怪兽改变表示形式为里侧守备表示
function c50615578.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 改变目标怪兽为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 过滤满足条件的怪兽：表侧守备表示且名字带有「机巧」
function c50615578.drfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x11)
end
-- 计算满足条件的怪兽数量并设置抽卡效果的目标玩家和参数
function c50615578.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上满足条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c50615578.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否可以发动抽卡效果
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为抽卡数量
	Duel.SetTargetParam(ct)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 执行抽卡效果，抽取满足条件的怪兽数量的卡
function c50615578.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上满足条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c50615578.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,ct,REASON_EFFECT)
end
