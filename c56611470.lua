--アーティファクトの解放
-- 效果：
-- 选择自己场上2只名字带有「古遗物」的怪兽才能发动。只用选择的2只怪兽为素材把1只超量怪兽超量召唤。这张卡发动过的回合，名字带有「古遗物」的怪兽以外的自己场上的怪兽不能攻击。此外，这张卡被对方破坏的场合，把手卡1只光属性·5星怪兽给对方观看才能发动。从卡组抽1张卡。
function c56611470.initial_effect(c)
	-- 选择自己场上2只名字带有「古遗物」的怪兽才能发动。只用选择的2只怪兽为素材把1只超量怪兽超量召唤。这张卡发动过的回合，名字带有「古遗物」的怪兽以外的自己场上的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c56611470.target)
	e1:SetOperation(c56611470.activate)
	c:RegisterEffect(e1)
	-- 此外，这张卡被对方破坏的场合，把手卡1只光属性·5星怪兽给对方观看才能发动。从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56611470,0))  --"抽卡"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c56611470.drcon)
	e2:SetCost(c56611470.drcost)
	e2:SetTarget(c56611470.drtg)
	e2:SetOperation(c56611470.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的名字带有「古遗物」且可以成为效果对象的怪兽
function c56611470.filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x97) and c:IsCanBeEffectTarget(e)
end
-- 过滤条件：可以用指定素材进行超量召唤的超量怪兽
function c56611470.xyzfilter(c,mg)
	return c:IsXyzSummonable(mg,2,2)
end
-- 过滤条件：检查是否存在另一只怪兽，能与当前怪兽一起作为素材超量召唤额外卡组的超量怪兽
function c56611470.mfilter1(c,mg,exg,tp)
	return mg:IsExists(c56611470.mfilter2,1,c,c,exg,tp)
end
-- 过滤条件：检查当前怪兽与mc组成的卡组是否能超量召唤额外卡组的超量怪兽
function c56611470.mfilter2(c,mc,exg,tp)
	local g=Group.FromCards(c,mc)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,g)
end
-- 效果1（超量召唤）的发动准备与目标选择
function c56611470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有满足条件的「古遗物」怪兽
	local mg=Duel.GetMatchingGroup(c56611470.filter,tp,LOCATION_MZONE,0,nil,e)
	-- 获取额外卡组中可以用上述「古遗物」怪兽作为素材超量召唤的超量怪兽
	local exg=Duel.GetMatchingGroup(c56611470.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if chk==0 then return mg:IsExists(c56611470.mfilter1,1,nil,mg,exg,tp) end
	-- 提示玩家选择要作为超量素材的第一只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local sg1=mg:FilterSelect(tp,c56611470.mfilter1,1,1,nil,mg,exg,tp)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择要作为超量素材的第二只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local sg2=mg:FilterSelect(tp,c56611470.mfilter2,1,1,tc1,tc1,exg,tp)
	sg1:Merge(sg2)
	-- 将选择的2只怪兽设为效果处理的对象
	Duel.SetTargetCard(sg1)
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：仍存在于场上且表侧表示的对象怪兽
function c56611470.tfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
-- 效果1（超量召唤）的效果处理
function c56611470.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡发动过的回合，名字带有「古遗物」的怪兽以外的自己场上的怪兽不能攻击。此外，这张卡被对方破坏的场合，把手卡1只光属性·5星怪兽给对方观看才能发动。从卡组抽1张卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c56611470.attg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：本回合非「古遗物」怪兽不能攻击
	Duel.RegisterEffect(e1,tp)
	-- 获取仍存在于场上且表侧表示的对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c56611470.tfilter,nil,e)
	if g:GetCount()<2 then return end
	-- 获取额外卡组中可以用这2只怪兽作为素材超量召唤的超量怪兽
	local xyzg=Duel.GetMatchingGroup(c56611470.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用选定的2只怪兽作为素材，对选定的超量怪兽进行超量召唤
		Duel.XyzSummon(tp,xyz,g)
	end
end
-- 过滤条件：非「古遗物」怪兽（用于限制攻击）
function c56611470.attg(e,c)
	return not c:IsSetCard(0x97)
end
-- 效果2（抽卡）的发动条件：被对方破坏且原本由自己控制
function c56611470.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤条件：手卡中未公开的光属性·5星怪兽
function c56611470.cffilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(5) and not c:IsPublic()
end
-- 效果2（抽卡）的发动代价：展示手卡1只光属性·5星怪兽
function c56611470.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可展示的光属性·5星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56611470.cffilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的光属性·5星怪兽
	local g=Duel.SelectMatchingCard(tp,c56611470.cffilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 效果2（抽卡）的发动准备与目标确认
function c56611470.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果2（抽卡）的效果处理
function c56611470.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
