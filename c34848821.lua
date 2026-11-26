--痕喰竜ブリガンド
-- 效果：
-- 「阿不思的落胤」＋8星以上的怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：只要融合召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他怪兽作为怪兽的效果的对象。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「铁兽」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c34848821.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：「阿不思的落胤」(68468459)＋1只8星以上的怪兽（允许融合素材替代与额外条件）
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsLevelAbove,8),1,true,true)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要融合召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他怪兽作为怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c34848821.imcon)
	e2:SetTarget(c34848821.imval)
	e2:SetValue(c34848821.imfilter)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的结束阶段
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c34848821.regop)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。才能发动。从卡组选1只「铁兽」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34848821,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,34848821)
	e4:SetCondition(c34848821.thcon)
	e4:SetTarget(c34848821.thtg)
	e4:SetOperation(c34848821.thop)
	c:RegisterEffect(e4)
end
-- 烙印融合专用素材检查函数：判断所选素材组sg是否由「阿不思的落胤」(68468459)与1只8星以上怪兽组成
function c34848821.branded_fusion_check(tp,sg,fc)
	-- 调用aux.gffcheck检查两张素材是否分别满足融合卡名「阿不思的落胤」与等级8以上的条件
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsLevelAbove,8)
end
-- 效果②的Condition函数：检查这张卡是否是通过融合召唤方式登场的
function c34848821.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果②的Target过滤函数：使保护效果仅适用于自己场上除这张卡自身以外的其他怪兽
function c34848821.imval(e,c)
	return c~=e:GetHandler()
end
-- 效果②的Value过滤函数：限制仅针对对方发动的怪兽效果，使其无法以这些怪兽为对象
function c34848821.imfilter(e,re,rp)
	-- 检查效果发动者是否为对方（aux.tgoval）且发动的卡片类型为怪兽效果
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- 持续监听效果③的Operation函数：当这张卡送入墓地时为其注册持续至本回合结束阶段的标记34848821
function c34848821.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34848821,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③的Condition函数：检查墓地中的这张卡是否带有本回合送去墓地的标记34848821
function c34848821.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34848821)>0
end
-- 过滤函数：筛选卡组中「铁兽」(0x14d)怪兽或「阿不思的落胤」(68468459)，且可加入手卡或在有空位时可特殊召唤
function c34848821.thfilter(c,e,tp)
	if not (c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果③的Target函数：检测己方卡组中是否存在满足检索或特召条件的怪兽
function c34848821.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1只符合条件的「铁兽」怪兽或「阿不思的落胤」
	if chk==0 then return Duel.IsExistingMatchingCard(c34848821.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果③的Operation函数：从卡组选1只「铁兽」怪兽或「阿不思的落胤」，根据可操作性及玩家选择加入手卡或表侧特殊召唤
function c34848821.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要操作的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的「铁兽」怪兽或「阿不思的落胤」
	local g=Duel.SelectMatchingCard(tp,c34848821.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若该卡可加入手卡，且无法特召、没有空位或玩家在加入手卡(1190)与特召(1152)间选择了加入手卡，则执行回手分支
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 以效果将选中的怪兽加入其持有者（己方）手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
