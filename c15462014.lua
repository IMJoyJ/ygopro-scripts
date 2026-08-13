--龍馬躓図
-- 效果：
-- 从额外卡组特殊召唤的怪兽在双方场上存在的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，从额外卡组特殊召唤的表侧表示怪兽的效果无效化。
-- ②：从额外卡组特殊召唤的怪兽之间的战斗让怪兽被破坏的场合发动。这张卡送去墓地，那次战斗破坏的怪兽的控制者受到1000伤害。
function c15462014.initial_effect(c)
	-- 从额外卡组特殊召唤的怪兽在双方场上存在的场合才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c15462014.actcon)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，从额外卡组特殊召唤的表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c15462014.distg)
	c:RegisterEffect(e2)
	-- ②：从额外卡组特殊召唤的怪兽之间的战斗让怪兽被破坏的场合发动。这张卡送去墓地，那次战斗破坏的怪兽的控制者受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c15462014.tgcon)
	e3:SetTarget(c15462014.tgtg)
	e3:SetOperation(c15462014.tgop)
	c:RegisterEffect(e3)
end
-- 筛选条件：判断怪兽是否为从额外卡组特殊召唤（其召唤位置为额外卡组），用于发动条件和对象筛选。
function c15462014.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动条件判定：检查自己场上和对方场上是否都至少存在1只从额外卡组特殊召唤的怪兽，满足才能发动此卡。
function c15462014.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只从额外卡组特殊召唤的怪兽。
	return Duel.IsExistingMatchingCard(c15462014.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在至少1只从额外卡组特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c15462014.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 无效对象的判定：作为①效果的无效对象，筛选场上从额外卡组特殊召唤的表侧表示怪兽，使其效果无效化。
function c15462014.distg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 战斗破坏事件筛选：被破坏的怪兽c与其战斗对象d都必须是额外卡组特殊召唤的怪兽，即这两只怪兽之间的战斗导致破坏。
function c15462014.egfilter(c)
	local d=c:GetBattleTarget()
	return c:IsSummonLocation(LOCATION_EXTRA) and d:IsSummonLocation(LOCATION_EXTRA)
end
-- 判断被破坏怪兽的上一个控制者是否为tp，用于确定该怪兽的控制者并获得伤害。
function c15462014.pcheck(c,tp)
	return c:IsPreviousControler(tp)
end
-- 触发条件判定：本次被战斗破坏的怪兽组中，存在至少1只满足“与额外卡组特殊召唤的怪兽战斗而被破坏”的怪兽，则效果触发。
function c15462014.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15462014.egfilter,1,nil)
end
-- 效果发动时的目标处理：chk==0时直接返回true（必发效果无发动条件）；设置送墓和伤害的操作信息；根据被破坏怪兽的控制者确定伤害对象：若只有一方有则只对该玩家伤害，若双方都有则玩家为PLAYER_ALL。
function c15462014.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果处理时会将这张卡自身送去墓地（CATEGORY_TOGRAVE），数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	local tg,pct,player=eg:Filter(c15462014.egfilter,nil),0,0
	for p=0,1 do
		if tg:IsExists(c15462014.pcheck,1,nil,p) then
			pct=pct+1
			player=p
		end
	end
	if pct==2 then player=PLAYER_ALL end
	-- 设置操作信息：效果处理时会对玩家造成1000点伤害（CATEGORY_DAMAGE），伤害对象由前面计算的控制者决定；若双方都有被破坏怪兽则为PLAYER_ALL。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,player,1000)
end
-- 效果处理：此卡仍与效果相关时，先将自身送墓；然后筛选出所有符合条件的被破坏怪兽；对于每个控制者p，给予1000点效果伤害（分阶段），最后调用RDComplete完成时点。
function c15462014.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以效果原因送去墓地（作为②效果处理中规定的送墓动作）。
		Duel.SendtoGrave(c,REASON_EFFECT)
		local tg=eg:Filter(c15462014.egfilter,nil)
		for p=0,1 do
			if tg:IsExists(c15462014.pcheck,1,nil,p) then
				-- 给玩家p造成1000点效果伤害，is_step=true表示作为伤害处理的一步，以便触发相关时点。
				Duel.Damage(p,1000,REASON_EFFECT,true)
			end
		end
		-- 完成伤害/回复的阶段处理，触发在伤害后等待的时点（如被破坏怪兽的遗言或诱发效果）。
		Duel.RDComplete()
	end
end
