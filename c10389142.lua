--No.42 スターシップ・ギャラクシー・トマホーク
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡2个超量素材取除才能发动。在自己场上把「战鹰衍生物」（机械族·风·6星·攻2000/守0）尽可能特殊召唤。这个效果特殊召唤的衍生物在这个回合的结束阶段破坏。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
function c10389142.initial_effect(c)
	-- 添加超量召唤手续，以2只7星怪兽为素材
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
-- 设定此卡的「No.」编号为42
aux.xyz_number[10389142]=42
-- 效果发动成本：取除此卡的2个超量素材
function c10389142.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 特殊召唤发动的操作准备阶段，确认自己场上是否有空闲区域且玩家是否能特殊召唤衍生物，并设置特殊召唤和衍生物的操作信息
function c10389142.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空置的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并判断玩家是否可以特殊召唤「战鹰衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,10389143,0,TYPES_TOKEN_MONSTER,2000,0,6,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置产生衍生物的操作信息，数量为可特招怪兽区域数量值
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置特殊召唤的操作信息，数量为可特招怪兽区域数量值
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
end
-- 效果处理阶段，首先适用直到回合结束对方收到的战斗伤害变0的效果，并在自己场上尽可能特殊召唤「战鹰衍生物」，同时注册这些衍生物在结束阶段破坏的延迟效果
function c10389142.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在自己场上把「战鹰衍生物」（机械族·风·6星·攻2000/守0）尽可能特殊召唤。这个效果特殊召唤的衍生物在这个回合的结束阶段破坏。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(0,1)
	e0:SetValue(1)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册对方收到的战斗伤害变成0的玩家效果
	Duel.RegisterEffect(e0,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否有可用怪兽区域，以及是否可以特殊召唤衍生物
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,10389143,0,TYPES_TOKEN_MONSTER,2000,0,6,RACE_MACHINE,ATTRIBUTE_WIND) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	local g=Group.CreateGroup()
	for i=1,ft do
		-- 在系统后台创建一张「战鹰衍生物」卡片数据
		local token=Duel.CreateToken(tp,10389143)
		-- 进行产生衍生物并放至场上的单步特殊召唤步骤
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		token:RegisterFlagEffect(10389142,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		g:AddCard(token)
	end
	-- 完成所有被积攒怪兽的特殊召唤
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 这个效果特殊召唤的衍生物在这个回合的结束阶段破坏。
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
	-- 注册在回合结束阶段破坏衍生物的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤带有本效果特招标记（标识符一致）的衍生物卡片
function c10389142.desfilter(c,fid)
	return c:GetFlagEffectLabel(10389142)==fid
end
-- 检查是否仍有本效果特招的衍生物存活，如果没有则清除该效果
function c10389142.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c10389142.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 筛选出所有带有本效果特招标记的衍生物并将其破坏
function c10389142.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c10389142.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 以效果破坏所有筛选出来的存活衍生物
	Duel.Destroy(tg,REASON_EFFECT)
end
