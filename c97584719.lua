--無限起動アースシェイカー
-- 效果：
-- 9星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡的超量素材任意数量取除，以那个数量的场上的卡为对象才能发动。那些卡破坏。
-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
function c97584719.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤手续：9星怪兽2只
	aux.AddXyzProcedure(c,nil,9,2)
	-- ①：把这张卡的超量素材任意数量取除，以那个数量的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97584719,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97584719)
	e1:SetCost(c97584719.descost)
	e1:SetTarget(c97584719.destg)
	e1:SetOperation(c97584719.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97584719,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c97584719.xyzcon)
	e2:SetTarget(c97584719.xyztg)
	e2:SetOperation(c97584719.xyzop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97584719,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,97584720)
	e3:SetCost(c97584719.spcost)
	e3:SetTarget(c97584719.sptg)
	e3:SetOperation(c97584719.spop)
	c:RegisterEffect(e3)
end
-- 效果①的Cost（发动代价）函数：取除任意数量的超量素材，并记录取除的数量
function c97584719.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取场上可以作为效果对象的卡片数量，作为可取除素材的最大数量限制
	local rt=Duel.GetTargetCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 效果①的Target（效果目标）确定函数：选择与取除素材数量相同的场上的卡作为对象
function c97584719.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 给玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择与取除素材数量（ct）相同的场上的卡作为效果对象
	local tg=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置连锁信息，表示该效果的操作是破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,ct,0,0)
end
-- 效果①的Operation（效果处理）函数：破坏作为对象的卡
function c97584719.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果破坏这些卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②的Condition（发动条件）函数：检查自身是否仍在战斗，以及被战斗破坏的怪兽是否满足重叠为素材的条件
function c97584719.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() then return false end
	e:SetLabelObject(tc)
	return tc and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsCanOverlay()
		and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup() and tc:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
-- 效果②的Target（效果目标）确定函数：检查自身是否为XYZ怪兽，并将被破坏的怪兽设为效果处理的目标
function c97584719.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
	local tc=e:GetLabelObject()
	-- 将被战斗破坏的怪兽设置为当前连锁的处理对象
	Duel.SetTargetCard(tc)
	-- 设置连锁信息，表示该效果包含使卡片离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果②的Operation（效果处理）函数：将被破坏的怪兽重叠作为自身的超量素材
function c97584719.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为目标的被破坏怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠在自身下方作为超量素材
		Duel.Overlay(c,tc)
	end
end
-- 过滤函数：筛选场上解放后能空出怪兽区域的机械族连接怪兽
function c97584719.cfilter(c,tp)
	-- 检查卡片是否为机械族连接怪兽，且解放该卡后自身能特殊召唤到怪兽区域
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_MACHINE) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果③的Cost（发动代价）函数：解放自己场上1只机械族连接怪兽
function c97584719.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以解放的满足条件的机械族连接怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c97584719.cfilter,1,nil,tp) end
	-- 玩家选择1只满足条件的机械族连接怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c97584719.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果③的Target（效果目标）确定函数：检查自身是否能守备表示特殊召唤，并设置特殊召唤的连锁信息
function c97584719.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁信息，表示该效果的操作是特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的Operation（效果处理）函数：将自身守备表示特殊召唤
function c97584719.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
