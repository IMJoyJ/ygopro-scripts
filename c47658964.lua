--紅蓮の炎壁
-- 效果：
-- 把自己墓地存在的名字带有「熔岩」的怪兽任意数量从游戏中除外发动。为这张卡发动而除外的怪兽数量的「熔岩衍生物」（炎族·炎·1星·攻/守0）在自己场上守备表示特殊召唤。
function c47658964.initial_effect(c)
	-- 把自己墓地存在的名字带有「熔岩」的怪兽任意数量从游戏中除外发动。为这张卡发动而除外的怪兽数量的「熔岩衍生物」（炎族·炎·1星·攻/守0）在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c47658964.cost)
	e1:SetTarget(c47658964.target)
	e1:SetOperation(c47658964.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选出名字带有「熔岩」字段且可以作为代价从墓地除外的怪兽。
function c47658964.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 支付代价：从自己墓地的「熔岩」怪兽中选择任意数量（受可用怪兽区空格数限制，若「青眼精灵龙」效果适用中则最多1只）除外，并将选择的数量记录到效果标签中。
function c47658964.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己墓地存在至少1只可除外且带有「熔岩」字段的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c47658964.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 取得自己场上可用的主要怪兽区空格数，用于限制可选择除外的怪兽数量（因为之后要特殊召唤相同数量的衍生物）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 给玩家显示“请选择要除外的卡”的提示，并让玩家进入除外的选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地的「熔岩」怪兽中选择1至ft张（ft为可用空格数）作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c47658964.cfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
	e:SetLabel(g:GetCount())
	-- 将所选怪兽从游戏中表侧除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的目标判定：确认自己场上存在可用怪兽区空格，且自己可以特殊召唤「熔岩衍生物」；然后登记后续生成衍生物和特殊召唤的操作信息。
function c47658964.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己能够在主要怪兽区以表侧守备表示特殊召唤「熔岩衍生物」（炎族·炎·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,47658965,0x39,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE) end
	-- 登记生成衍生物的操作信息：将生成「熔岩衍生物」，数量为发动时除外的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,e:GetLabel(),0,0)
	-- 登记特殊召唤的操作信息：将特殊召唤的「熔岩衍生物」数量为发动时除外的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),0,0)
end
-- 效果处理：若可用怪兽区空格数少于需要特招的衍生物数、或不能特招衍生物、或「青眼精灵龙」效果适用中且衍生物数量大于1，则效果不处理；否则逐个生成并特殊召唤衍生物。
function c47658964.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前自己场上可用的主要怪兽区空格数，用于判断能否成功特殊召唤全部衍生物。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若空格数不足、或不能特殊召唤「熔岩衍生物」，则本次效果处理失败（不进行特殊召唤）。
	if ft<e:GetLabel() or not Duel.IsPlayerCanSpecialSummonMonster(tp,47658965,0x39,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or (e:GetLabel()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	for i=1,e:GetLabel() do
		-- 创建1只「熔岩衍生物」（卡号47658965）到玩家tp场上。
		local token=Duel.CreateToken(tp,47658965)
		-- 将创建的衍生物以表侧守备表示加入特殊召唤处理（此步骤为连续特殊召唤的一环）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成连续特殊召唤处理，正式把全部衍生物特殊召唤到场上。
	Duel.SpecialSummonComplete()
end
