--シンデレラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡·卡组把1只「南瓜马车」特殊召唤。场地区域有「急流山的金宫」存在的场合，可以再从卡组把1张「水晶鞋」给这张卡装备。
-- ②：这张卡直接攻击给与对方战斗伤害时，以这张卡装备的1张「水晶鞋」和场上1只表侧表示怪兽为对象才能发动。那张「水晶鞋」给那只怪兽装备。
function c78527720.initial_effect(c)
	-- 注册卡片关联密码，表示本卡的效果记有「急流山的金宫」的卡名
	aux.AddCodeList(c,72283691)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡·卡组把1只「南瓜马车」特殊召唤。场地区域有「急流山的金宫」存在的场合，可以再从卡组把1张「水晶鞋」给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78527720,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,78527720)
	e1:SetTarget(c78527720.target)
	e1:SetOperation(c78527720.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡直接攻击给与对方战斗伤害时，以这张卡装备的1张「水晶鞋」和场上1只表侧表示怪兽为对象才能发动。那张「水晶鞋」给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78527720,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c78527720.eqcon)
	e3:SetTarget(c78527720.eqtg)
	e3:SetOperation(c78527720.eqop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为「南瓜马车」且可以特殊召唤
function c78527720.filter(c,e,tp)
	return c:IsCode(14512825) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：检查卡片是否为「水晶鞋」且可以装备给指定怪兽
function c78527720.efilter(c,ec)
	return c:IsCode(9677699) and c:CheckEquipTarget(ec)
end
-- 效果①的发动准备：检查怪兽区域空位以及手卡·卡组是否存在可特殊召唤的「南瓜马车」
function c78527720.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在至少1只可以特殊召唤的「南瓜马车」
		and Duel.IsExistingMatchingCard(c78527720.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示此效果包含从手卡或卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的效果处理：特殊召唤「南瓜马车」，并根据条件决定是否从卡组装备「水晶鞋」
function c78527720.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查主要怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只「南瓜马车」
	local g=Duel.SelectMatchingCard(tp,c78527720.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功将选择的怪兽以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场地区域是否存在「急流山的金宫」，且自身的魔法与陷阱区域有空位
		and Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在可以装备给这张卡的「水晶鞋」
		and Duel.IsExistingMatchingCard(c78527720.efilter,tp,LOCATION_DECK,0,1,nil,c)
		-- 检查这张卡是否仍在场上表侧表示存在，并让玩家选择是否从卡组装备「水晶鞋」
		and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(78527720,1)) then  --"是否装备「水晶鞋」？"
		-- 中断当前效果处理，使后续的装备处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从卡组选择1张可以装备给这张卡的「水晶鞋」
		local eqg=Duel.SelectMatchingCard(tp,c78527720.efilter,tp,LOCATION_DECK,0,1,1,nil,c)
		-- 将选择的「水晶鞋」作为装备卡装备给这张卡
		Duel.Equip(tp,eqg:GetFirst(),c)
	end
end
-- 效果②的发动条件：给与对方玩家战斗伤害，且是直接攻击
function c78527720.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查受到伤害的玩家是对方，且攻击宣言时没有攻击对象（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 过滤函数：检查卡片是否为装备在自身身上的「水晶鞋」，且场上存在其他可以装备该「水晶鞋」的表侧表示怪兽
function c78527720.eqfilter(c,tc,tp)
	return c:IsCode(9677699) and tc:GetEquipGroup():IsContains(c)
		-- 检查场上是否存在除自身以外、可以装备该「水晶鞋」的表侧表示怪兽
		and Duel.IsExistingTarget(c78527720.eqtfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,tc,c)
end
-- 过滤函数：检查怪兽是否为表侧表示，且是该「水晶鞋」的合法装备对象
function c78527720.eqtfilter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
-- 效果②的发动准备：选择自身装备的1张「水晶鞋」和场上1只表侧表示怪兽为对象
function c78527720.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 检查自身魔法与陷阱区域是否存在满足条件的「水晶鞋」作为对象
	if chk==0 then return Duel.IsExistingTarget(c78527720.eqfilter,tp,LOCATION_SZONE,0,1,nil,c,tp) end
	-- 提示玩家选择要装备的卡（此处指要转移的「水晶鞋」）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自身装备的1张「水晶鞋」作为第一个效果对象
	local tc=Duel.SelectTarget(tp,c78527720.eqfilter,tp,LOCATION_SZONE,0,1,1,nil,c,tp):GetFirst()
	e:SetLabelObject(tc)
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽（除自身外）作为第二个效果对象
	Duel.SelectTarget(tp,c78527720.eqtfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tc)
end
-- 效果②的效果处理：将作为对象的「水晶鞋」装备给作为对象的另一只怪兽
function c78527720.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local sc=g:GetNext()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or sc:IsFacedown() or not sc:IsRelateToEffect(e) then return end
	local ec=e:GetLabelObject()
	if tc==ec then tc=sc end
	-- 将「水晶鞋」装备给目标怪兽
	Duel.Equip(tp,ec,tc)
end
