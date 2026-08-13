--幻獣機ドラゴサック
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
-- ②：只要自己场上有衍生物存在，这张卡不会被战斗·效果破坏。
-- ③：1回合1次，把自己场上1只「幻兽机」怪兽解放，以场上1张卡为对象才能发动。那张卡破坏。这个效果发动的回合，这张卡不能攻击。
function c22110647.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：素材为7星怪兽×2。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ②：只要自己场上有衍生物存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置②效果（战斗破坏免疫）的条件：自己场上有衍生物存在。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22110647,0))  --"在自己场上把2只「幻兽机衍生物」特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c22110647.spcost)
	e4:SetTarget(c22110647.sptg)
	e4:SetOperation(c22110647.spop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，把自己场上1只「幻兽机」怪兽解放，以场上1张卡为对象才能发动。那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22110647,1))  --"选择场上1张卡破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetCost(c22110647.descost)
	e5:SetTarget(c22110647.destg)
	e5:SetOperation(c22110647.desop)
	c:RegisterEffect(e5)
end
-- ①效果的代价：取除这张卡1个超量素材。chk==0时检查能否取除，实际取除1个超量素材。
function c22110647.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动条件：当前未受青眼精灵龙限制（不能同时特召2只以上）、自己主要怪兽区空格>1、且玩家能特殊召唤幻兽机衍生物。
function c22110647.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区剩余空格大于1，确保能放置2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能够特殊召唤指定的“幻兽机衍生物”（机械族·风·3星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 登记操作信息：本效果涉及生成衍生物，种类为CATEGORY_TOKEN，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 登记操作信息：本效果涉及特殊召唤，种类为CATEGORY_SPECIAL_SUMMON，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果处理：若仍不受青眼精灵龙限制且场地足够，则生成2只幻兽机衍生物并分步特殊召唤，最后完成特殊召唤。
function c22110647.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再次检查自己主要怪兽区空格是否大于1；若不满足则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 处理时再次检查玩家是否还能特殊召唤幻兽机衍生物；若可以则执行后续创建。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建第1只“幻兽机衍生物”（卡号22110648）。
		local token1=Duel.CreateToken(tp,22110648)
		-- 将第1只幻兽机衍生物以表侧攻击表示特殊召唤（分步特殊召唤第一步）。
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP)
		-- 创建第2只“幻兽机衍生物”（卡号22110648）。
		local token2=Duel.CreateToken(tp,22110648)
		-- 将第2只幻兽机衍生物以表侧攻击表示特殊召唤（分步特殊召唤第二步）。
		Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
		-- 完成分步特殊召唤，统一处理特殊召唤成功时点和诱发效果。
		Duel.SpecialSummonComplete()
	end
end
-- ③效果的代价检查：这张卡本回合尚未攻击过，且自己场上有「幻兽机」怪兽可解放。
function c22110647.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		-- 检查自己场上是否存在至少1张可解放的「幻兽机」字段怪兽（setcode=0x101b）。
		and Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x101b) end
	-- 选择自己场上1只「幻兽机」怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x101b)
	-- 将选择的怪兽解放（作为cost）。
	Duel.Release(g,REASON_COST)
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- ③效果的发动目标：选择场上1张卡为对象，且发动时需存在可选择的卡。
function c22110647.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查双方场上卡片总数大于1（保证对象选择时有卡可选）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>1
		-- 检查场上是否存在至少1张可以作为对象的卡（aux.TRUE→任意卡）。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示消息，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从场上选择1张卡作为效果对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：本效果破坏该对象卡，种类为CATEGORY_DESTROY，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：若对象仍与效果关联，则将其破坏。
function c22110647.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
