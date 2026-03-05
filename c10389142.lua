--No.42 スターシップ・ギャラクシー・トマホーク
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡2个超量素材取除才能发动。在自己场上把「战鹰衍生物」（机械族·风·6星·攻2000/守0）尽可能特殊召唤。这个效果特殊召唤的衍生物在这个回合的结束阶段破坏。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
function c10389142.initial_effect(c)
	-- 为卡片添加等级为7、需要2个超量素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除才能发动。在自己场上把「战鹰衍生物」（机械族·风·6星·攻2000/守0）尽可能特殊召唤。这个效果特殊召唤的衍生物在这个回合的结束阶段破坏。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetDescription(aux.Stringid(10389142,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c10389142.spcost)
	e1:SetTarget(c10389142.sptg)
	e1:SetOperation(c10389142.spop)
	c:RegisterEffect(e1)
end
-- 设置该卡的XYZ编号为42
aux.xyz_number[10389142]=42
-- 定义该效果的费用支付函数
function c10389142.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 定义该效果的发动时的处理函数
function c10389142.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,10389143,0,TYPES_TOKEN_MONSTER,2000,0,6,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置连锁操作信息：将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置连锁操作信息：将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 定义该效果的发动处理函数
function c10389142.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动后，直到回合结束时对方受到的战斗伤害变成0
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(0,1)
	e0:SetValue(1)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册战斗伤害免疫效果
	Duel.RegisterEffect(e0,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若场上无空位或无法特殊召唤衍生物则返回
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,10389143,0,TYPES_TOKEN_MONSTER,2000,0,6,RACE_MACHINE,ATTRIBUTE_WIND) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		-- 创建一个编号为10389143的衍生物
		local token=Duel.CreateToken(tp,10389143)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token:RegisterFlagEffect(10389142,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		g:AddCard(token)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 设置衍生物在结束阶段被破坏的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c10389142.descon)
	e1:SetOperation(c10389142.desop)
	-- 注册衍生物破坏效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义用于筛选衍生物的函数
function c10389142.desfilter(c,fid)
	return c:GetFlagEffectLabel(10389142)==fid
end
-- 定义衍生物破坏效果的触发条件
function c10389142.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c10389142.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 定义衍生物破坏效果的处理函数
function c10389142.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c10389142.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 将符合条件的衍生物破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
