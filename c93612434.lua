--デュアルウィール・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放，以自己墓地2只卡名不同的「弹丸」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「速射扳机」或者「重型扳机」加入手卡。
function c93612434.initial_effect(c)
	-- 在卡片关联代码列表中添加「速射扳机」和「重型扳机」的卡片密码
	aux.AddCodeList(c,20071842,67526112)
	-- ①：把这张卡解放，以自己墓地2只卡名不同的「弹丸」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93612434)
	e1:SetCost(c93612434.spcost)
	e1:SetTarget(c93612434.sptg)
	e1:SetOperation(c93612434.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「速射扳机」或者「重型扳机」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93612434,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,93612435)
	-- 把墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c93612434.thtg)
	e2:SetOperation(c93612434.thop)
	c:RegisterEffect(e2)
end
-- 效果①的代价过滤与支付函数
function c93612434.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自己场上的这张卡解放作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果①特殊召唤对象的过滤函数（墓地中满足条件的「弹丸」怪兽）
function c93612434.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x102) and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与目标选择（Target）函数
function c93612434.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c93612434.spfilter(chkc,e,tp) end
	-- 获取自己墓地所有满足特殊召唤条件的「弹丸」怪兽
	local g=Duel.GetMatchingGroup(c93612434.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:GetClassCount(Card.GetCode)>=2 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从怪兽组中筛选出2只卡名不同的怪兽
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的怪兽注册为本次效果的处理对象（取对象）
	Duel.SetTargetCard(g1)
	-- 设置连锁信息：包含特殊召唤2个怪兽对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果①的效果处理（Operation）函数
function c93612434.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的可使用格子数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取本次效果中被选择的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选择的怪兽守备表示特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②加入手卡对象的过滤函数（「速射扳机」或「重型扳机」）
function c93612434.thfilter(c)
	return c:IsCode(20071842,67526112) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择（Target）函数
function c93612434.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的可行性检测：检测卡组或墓地是否存在可加入手牌的对应卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c93612434.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁信息：包含从卡组或墓地将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）函数
function c93612434.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张满足条件的卡片（受王家长眠之谷影响判定限制）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c93612434.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
