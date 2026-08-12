--方界帝ヴァルカン・ドラグニー
-- 效果：
-- 这张卡不能通常召唤。把自己场上2只「方界」怪兽送去墓地的场合可以特殊召唤。
-- ①：这个方法特殊召唤的这张卡的攻击力上升1600。
-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
-- ③：这张卡战斗的伤害步骤结束时，以自己墓地最多3只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界超帝 死雷之印陀罗」加入手卡。
function c77387463.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上2只「方界」怪兽送去墓地的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c77387463.spcon)
	e2:SetTarget(c77387463.sptg)
	e2:SetOperation(c77387463.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡的特殊召唤成功的场合发动。给与对方800伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c77387463.damcon)
	e3:SetTarget(c77387463.damtg)
	e3:SetOperation(c77387463.damop)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗的伤害步骤结束时，以自己墓地最多3只「方界胤 毗贾姆」为对象才能发动。这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，可以从卡组把1只「方界超帝 死雷之印陀罗」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c77387463.sptg2)
	e4:SetOperation(c77387463.spop2)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示且可以送去墓地的「方界」怪兽
function c77387463.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件判定：检查场上是否存在2只满足条件的「方界」怪兽，且有足够的怪兽区域空位
function c77387463.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有表侧表示且可以送去墓地的「方界」怪兽
	local mg=Duel.GetMatchingGroup(c77387463.filter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否能选出2只怪兽，在它们送去墓地后能腾出足够的怪兽区域空位
	return mg:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤规则的准备阶段：选择要送去墓地的2只「方界」怪兽并保存
function c77387463.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有表侧表示且可以送去墓地的「方界」怪兽
	local mg=Duel.GetMatchingGroup(c77387463.filter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择2只在送去墓地后能腾出足够怪兽区域空位的「方界」怪兽
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行阶段：将选中的怪兽送去墓地，并适用攻击力上升的效果
function c77387463.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
	-- ①：这个方法特殊召唤的这张卡的攻击力上升1600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1600)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 伤害效果的发动条件：此卡是从手卡特殊召唤成功的场合
function c77387463.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 伤害效果的准备阶段：设置对方玩家为效果处理对象，并注册造成800伤害的操作信息
function c77387463.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为受到伤害的对象
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为800
	Duel.SetTargetParam(800)
	-- 注册给与对方800伤害的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果的执行阶段：给与对方800伤害
function c77387463.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤墓地中可以特殊召唤的「方界胤 毗贾姆」
function c77387463.spfilter(c,e,tp)
	return c:IsCode(15610297) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 遗言效果的准备阶段：确认自身在战斗后且墓地有「方界胤 毗贾姆」，并选择最多3只作为对象
function c77387463.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77387463.spfilter(chkc,e,tp) end
	-- 检查自身是否参与了战斗，以及自身离开场上后是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0 and c:IsRelateToBattle()
		-- 检查自己墓地是否存在至少1只可以特殊召唤的「方界胤 毗贾姆」
		and Duel.IsExistingTarget(c77387463.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ft=3
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算在自身离开场上后，最多可以特殊召唤的怪兽数量（不超过3只且不超过可用怪兽区域数）
	ft=math.min(ft,(Duel.GetMZoneCount(tp,e:GetHandler(),tp)))
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地最多3只「方界胤 毗贾姆」作为效果的对象
	local g=Duel.SelectTarget(tp,c77387463.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 注册特殊召唤这些对象的特殊召唤效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤卡组中可以加入手卡的「方界超帝 死雷之印陀罗」
function c77387463.thfilter(c)
	return c:IsCode(3775068) and c:IsAbleToHand()
end
-- 遗言效果的执行阶段：将自身送去墓地，特殊召唤作为对象的怪兽，并可选地从卡组检索「方界超帝 死雷之印陀罗」
function c77387463.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果关联，并尝试将自身送去墓地，若失败则终止处理
	if not c:IsRelateToEffect(e) or Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
	-- 获取当前自己场上可用的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取作为对象且仍满足效果条件的卡片组
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 尝试将选中的怪兽以表侧表示特殊召唤，若成功特殊召唤了至少1只则继续处理
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取卡组中所有的「方界超帝 死雷之印陀罗」
		local g=Duel.GetMatchingGroup(c77387463.thfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在该卡，询问玩家是否选择将其加入手卡
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(77387463,0)) then  --"是否把1只「方界超帝 死雷之印陀罗」加入手卡？"
			-- 中断当前效果处理，使后续的检索处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手卡的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			g=g:Select(tp,1,1,nil)
			-- 将选中的卡加入玩家手卡
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
