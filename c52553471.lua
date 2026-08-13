--融合超渦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽为对象才能发动。从手卡·卡组·额外卡组选「元素英雄」怪兽、「新空间侠」怪兽、10星怪兽之内1只给对方观看。这个回合，把作为对象的怪兽作为融合素材的场合，可以当作给人观看的怪兽的同名卡使用。自己的场上或者墓地有「元素英雄 新宇侠」存在的场合，给人观看的怪兽送去墓地。那以外的场合，从手卡给人观看的怪兽回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册『融合超涡』作为魔法卡的发动效果；该效果为自由时点取对象效果，1回合只能发动1次，发动时选择场上表侧表示怪兽为对象，处理时从手卡·卡组·额外卡组选择展示的怪兽，并适用融合素材同名化及后续送墓/回卡组。
function s.initial_effect(c)
	-- 将「元素英雄 新宇侠」的卡号登记到本卡，使本卡被视为记载着该卡名，用于判定『自己的场上或者墓地有「元素英雄 新宇侠」存在』。
	aux.AddCodeList(c,89943723)
	-- 将「元素英雄」系列字段登记到本卡，用于效果处理时正确筛选「元素英雄」怪兽。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
end
-- 定义对象怪兽的筛选条件：被选为对象的怪兽必须表侧表示，且手卡·卡组·额外卡组中存在至少1张可展示的符合条件的怪兽（「元素英雄」怪兽、「新空间侠」怪兽或10星怪兽）。
function s.tgfilter(c,tp)
	-- 判定怪兽是否为表侧表示，并且手卡·卡组·额外卡组中存在至少1张可供展示的「元素英雄」怪兽、「新空间侠」怪兽或10星怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c,tp)
end
-- 定义可展示卡片的筛选条件：不能与对象怪兽当前的融合识别卡名相同，且为怪兽，属于「新空间侠」或「元素英雄」系列，或等级为10。
function s.cfilter(c,tc,tp)
	if c:IsCode(tc:GetFusionCode()) then return false end
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x1f) or c:IsSetCard(0x3008) or c:IsLevel(10))
end
-- 效果发动时的目标选择处理：检查是否存在合法对象；若存在，提示玩家选择1只场上表侧表示怪兽作为对象，并将其设为效果对象。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	-- 在发动时判定是否存在至少1只满足条件的场上表侧表示怪兽可以作为对象，且存在可展示的卡片。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家显示『请选择效果的对象』的提示消息，引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方怪兽区域选择1只满足条件的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 定义『自己的场上或者墓地有「元素英雄 新宇侠」存在』的判定条件：存在卡号为89943723的「元素英雄 新宇侠」，且该卡在场上表侧表示或在墓地。
function s.neosfilter(c)
	return c:IsCode(89943723) and (c:IsFaceup() or not c:IsOnField())
end
-- 效果处理：确认对象仍相关且为表侧；从手卡·卡组·额外卡组选择1张符合条件的怪兽卡给对方确认；为对象怪兽赋予这个回合作为融合素材时可当作展示怪兽的同名卡的效果；若自己的场上或墓地存在「元素英雄 新宇侠」，则将展示卡送去墓地；否则，若展示卡来自手卡，则将其回到卡组并洗切。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的场上表侧表示怪兽作为对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家显示『请选择给对方确认的卡』的提示消息，提示从候选卡中选择展示给对方看的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡·卡组·额外卡组中筛选出1张符合条件的「元素英雄」怪兽、「新空间侠」怪兽或10星怪兽，并取得这张卡。
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc,tp):GetFirst()
	if cg==nil then return end
	-- 将选择的那张卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,cg)
	local code1,code2=cg:GetOriginalCodeRule()
	-- 这个回合，把作为对象的怪兽作为融合素材的场合，可以当作给人观看的怪兽的同名卡使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))  --"「融合超涡」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_FUSION_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code1)
	tc:RegisterEffect(e1)
	if code2 then
		local e2=e1:Clone()
		e2:SetValue(code2)
		tc:RegisterEffect(e2)
	end
	-- 判定自己的场上或墓地是否存在「元素英雄 新宇侠」，以决定展示卡的后续去向。
	if Duel.IsExistingMatchingCard(s.neosfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then
		-- 将给人观看的怪兽送去墓地。
		Duel.SendtoGrave(cg,REASON_EFFECT)
	elseif cg:IsLocation(LOCATION_HAND) then
		-- 将给人观看的怪兽（若是在手卡展示的）回到持有者卡组并洗切。
		Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
