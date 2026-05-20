--神聖騎士王コルネウス
-- 效果：
-- 4星「圣骑士」怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡的超量素材任意数量取除，以那个数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。「神圣骑士王 康尼厄斯」以外的1只「圣骑士」超量怪兽当作超量召唤从额外卡组特殊召唤，把墓地的这张卡在下面重叠作为超量素材。
function c78876707.initial_effect(c)
	-- 添加XYZ召唤手续：4星「圣骑士」怪兽2只以上进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：把这张卡的超量素材任意数量取除，以那个数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78876707,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,78876707)
	e1:SetCost(c78876707.thcost)
	e1:SetTarget(c78876707.thtg)
	e1:SetOperation(c78876707.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。「神圣骑士王 康尼厄斯」以外的1只「圣骑士」超量怪兽当作超量召唤从额外卡组特殊召唤，把墓地的这张卡在下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78876707,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c78876707.spcon)
	e2:SetTarget(c78876707.sptg)
	e2:SetOperation(c78876707.spop)
	c:RegisterEffect(e2)
end
-- 效果①的代价处理：检查并取除任意数量的超量素材，并记录取除的数量
function c78876707.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 获取对方场上可以回到手牌的卡片数量，作为取除素材数量的上限
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 效果①的靶向处理：确认是否有可返回手牌的卡，并选择与取除素材数量相同的对方场上的卡作为对象
function c78876707.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在至少1张可以回到手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择与取除素材数量相同的对方场上的卡作为效果对象
	local tg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果处理信息：将选中的对象卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,ct,0,0)
end
-- 效果①的操作处理：将成为对象的卡片送回持有者手牌
function c78876707.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local rg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将这些卡片因效果送回持有者的手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被战斗或效果破坏并送去墓地
function c78876707.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤条件：额外卡组中「神圣骑士王 康尼厄斯」以外的、可以进行XYZ特殊召唤的「圣骑士」超量怪兽
function c78876707.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and not c:IsCode(78876707) and c:IsType(TYPE_XYZ)
		-- 检查该怪兽是否能以XYZ召唤的方式特殊召唤，且额外区域有可用位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的靶向处理：检查是否满足特殊召唤条件，并设置特殊召唤和墓地卡片移动的操作信息
function c78876707.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为XYZ素材的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足条件的「圣骑士」超量怪兽
		and Duel.IsExistingMatchingCard(c78876707.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果处理信息：自身（墓地的这张卡）离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
-- 效果②的操作处理：从额外卡组将目标怪兽当作超量召唤特殊召唤，并将墓地的这张卡叠放在其下方作为超量素材
function c78876707.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查必须作为XYZ素材的限制，若不满足则不处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「圣骑士」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c78876707.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽以XYZ召唤的方式表侧表示特殊召唤，并判断是否特殊召唤成功
		if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
			if c:IsRelateToEffect(e) and c:IsCanOverlay() then
				-- 将墓地的这张卡重叠在特殊召唤的怪兽下面作为超量素材
				Duel.Overlay(tc,Group.FromCards(c))
			end
		end
	end
end
