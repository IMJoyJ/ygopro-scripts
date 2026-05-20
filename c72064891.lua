--魔道騎竜カース・オブ・ドラゴン
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 战士族怪兽＋5星以上的龙族怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤成功的场合，以有「龙骑士 盖亚」的卡名记述的自己墓地1张魔法·陷阱卡为对象才能发动。那张卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己把龙族·7星怪兽融合召唤的场合，也能把自己墓地的怪兽除外作为融合素材。
function c72064891.initial_effect(c)
	-- 注册卡片记述了「龙骑士 盖亚」（卡号66889139）的事实。
	aux.AddCodeList(c,66889139)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：战士族怪兽＋满足过滤条件2（5星以上的龙族怪兽）的怪兽。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),c72064891.matfilter2,true)
	-- ①：这张卡融合召唤成功的场合，以有「龙骑士 盖亚」的卡名记述的自己墓地1张魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72064891,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,72064891)
	e1:SetCondition(c72064891.thcon)
	e1:SetTarget(c72064891.thtg)
	e1:SetOperation(c72064891.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己把龙族·7星怪兽融合召唤的场合，也能把自己墓地的怪兽除外作为融合素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetTarget(c72064891.mttg)
	e2:SetValue(c72064891.mtval)
	c:RegisterEffect(e2)
	-- 检查是否已经全局重写了融合素材获取和送墓相关的系统函数，避免重复重写。
	if not aux.fus_mat_hack_check then
		-- 标记已进行融合素材系统函数的重写。
		aux.fus_mat_hack_check=true
		-- 定义过滤函数，用于筛选具有额外融合素材效果（如从墓地除外作为素材）的卡片。
		function aux.fus_mat_hack_exmat_filter(c)
			return c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,c:GetControler())
		end
		-- 保存系统原有的获取融合素材函数。
		_GetFusionMaterial=Duel.GetFusionMaterial
		-- 重写获取融合素材的系统函数，以支持从墓地等额外区域获取融合素材。
		function Duel.GetFusionMaterial(tp,loc)
			if loc==nil then loc=LOCATION_HAND+LOCATION_MZONE end
			local g=_GetFusionMaterial(tp,loc)
			-- 获取额外区域中具有额外融合素材效果的卡片组。
			local exg=Duel.GetMatchingGroup(aux.fus_mat_hack_exmat_filter,tp,LOCATION_EXTRA,0,nil)
			return g+exg
		end
		-- 保存系统原有的送去墓地函数。
		_SendtoGrave=Duel.SendtoGrave
		-- 重写送去墓地的系统函数，以便在融合召唤时将作为素材的墓地怪兽改为除外。
		function Duel.SendtoGrave(tg,reason)
			-- 如果不是因为融合召唤效果将素材送去墓地，或者操作对象不是卡片组，则执行原有的送墓处理。
			if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
				return _SendtoGrave(tg,reason)
			end
			-- 筛选出原本在额外或墓地且具有额外融合素材效果的卡片。
			local tc=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE):Filter(aux.fus_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			tg:Sub(rg)
			local ct1=_SendtoGrave(tg,reason)
			-- 将原本就在墓地的融合素材怪兽以相同原因表侧表示除外。
			local ct2=Duel.Remove(rg,POS_FACEUP,reason)
			return ct1+ct2
		end
	end
end
-- 融合素材过滤条件：5星以上的龙族怪兽。
function c72064891.matfilter2(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动条件：这张卡融合召唤成功。
function c72064891.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索对象的过滤条件：有「龙骑士 盖亚」卡名记述的魔法·陷阱卡，且能加入手卡。
function c72064891.thfilter(c)
	-- 判定卡片是否记述了「龙骑士 盖亚」且是魔法·陷阱卡，并且能加入手卡。
	return aux.IsCodeListed(c,66889139) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备（判定是否满足发动条件、选择墓地的目标卡片、设置操作信息）。
function c72064891.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72064891.thfilter(chkc) end
	-- 判定自己墓地是否存在满足条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c72064891.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c72064891.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理（将作为对象的卡加入手牌）。
function c72064891.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 额外融合素材的适用条件：必须是怪兽卡且可以被除外。
function c72064891.mttg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 额外融合素材的判定函数，返回true表示可以作为融合素材。
function c72064891.mtval(e,c)
	if not c then return true end
	return true
end
